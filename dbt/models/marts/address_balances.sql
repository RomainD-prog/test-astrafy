-- Data mart: current balance per address, EXCLUDING any address that ever
-- appeared in a coinbase (mining-reward) transaction.
--
-- Balance logic on the UTXO model:
--   * an address is CREDITED by the outputs it receives;
--   * an address is DEBITED by the inputs it spends;
--   * balance = sum(credits) - sum(debits).
--
-- Scope note: computed over the staging window (last 3 months) to stay in the
-- free tier, so this is a net balance over that window, not the full history.

with transactions as (

    select * from {{ ref('stg_transactions') }}

),

-- Money received by each address (outputs).
credits as (
    select
        address,
        output.value as value
    from transactions,
        unnest(outputs) as output,
        unnest(output.addresses) as address
),

-- Money spent by each address (inputs).
debits as (
    select
        address,
        input.value as value
    from transactions,
        unnest(inputs) as input,
        unnest(input.addresses) as address
),

-- Addresses that appear in at least one coinbase transaction output.
coinbase_addresses as (
    select distinct address
    from transactions,
        unnest(outputs) as output,
        unnest(output.addresses) as address
    where is_coinbase is true
),

movements as (
    select address, value from credits
    union all
    select address, -1 * value from debits
),

balances as (
    select
        address,
        sum(value) as balance_satoshi
    from movements
    group by address
)

select
    b.address,
    b.balance_satoshi,
    b.balance_satoshi / 100000000 as balance_bch
from balances as b
left join coinbase_addresses as c
    on b.address = c.address
where c.address is null
