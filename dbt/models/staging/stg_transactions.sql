{{
    config(
        materialized = "table",
        partition_by = {
            "field": "block_timestamp",
            "data_type": "timestamp",
            "granularity": "day",
        },
    )
}}

-- Staging model: only the last N months of raw transactions (default 3).
--
-- The public crypto_bitcoin_cash dataset is no longer updated in real time, so
-- the window is anchored on the LATEST date available in the source rather than
-- on today's date (otherwise the result would be empty). The cut-off is resolved
-- ONCE via run_query, then injected as a literal so BigQuery can prune partitions
-- (block_timestamp_month) and keep the scan within the free tier.

{%- set months = var('transactions_lookback_months', 3) -%}

{%- if execute -%}
    {% set cutoff_query %}
        select cast(
    date_sub(date(max(block_timestamp_month)), interval {{ months - 1 }} month) as string
) as cutoff_date
        from {{ source('crypto_bitcoin_cash', 'transactions') }}
    {% endset %}
    {%- set cutoff_date = run_query(cutoff_query).columns[0].values()[0] -%}
{%- else -%}
    {%- set cutoff_date = '1970-01-01' -%}
{%- endif %}

with source as (
    select *
    from {{ source('crypto_bitcoin_cash', 'transactions') }}
    where block_timestamp_month >= date('{{ cutoff_date }}')
)

select
    `hash` as transaction_hash,
    block_hash,
    block_number,
    block_timestamp,
    block_timestamp_month,
    is_coinbase,
    input_count,
    output_count,
    input_value,
    output_value,
    fee,
    inputs,
    outputs
from source
