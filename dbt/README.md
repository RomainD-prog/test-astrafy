# dbt — Bitcoin Cash transformations

dbt-core project running on BigQuery. It materializes:

1. **`staging.stg_transactions`** — the last 3 months of
   `bigquery-public-data.crypto_bitcoin_cash.transactions`.
2. **`data_mart.address_balances`** — the current balance per address,
   excluding any address involved in a coinbase transaction.

## Layout

```
dbt/
├── dbt_project.yml
├── profiles.yml                # BigQuery via ADC (oauth) — no key in repo
├── packages.yml               # dbt_utils
├── macros/
│   └── generate_schema_name.sql  # map models to exact datasets
└── models/
    ├── staging/
    │   ├── _staging__sources.yml
    │   ├── stg_transactions.sql
    │   └── _staging__models.yml
    └── marts/
        ├── address_balances.sql
        └── _marts__models.yml
```

## Run locally

```bash
cd dbt

# 1. Auth (Application Default Credentials)
gcloud auth application-default login

# 2. Point dbt at the project created by Terraform
export DBT_PROJECT_ID="<project_id>"
export DBT_BQ_LOCATION="US"          # must match the source public dataset (US)

# 3. Install deps and build (run + tests)
dbt deps
dbt build
```

`dbt build` runs the models and their tests. Use `dbt run` for models only.

## Configuration

| Setting | Where | Default |
|---|---|---|
| Months kept in staging | `vars.transactions_lookback_months` (`dbt_project.yml`) | `3` |
| Target project | `DBT_PROJECT_ID` env var | — |
| Datasets location | `DBT_BQ_LOCATION` env var | `US` |
| Staging dataset | `DBT_STAGING_DATASET` env var | `staging` |

## Design notes

- **Schema mapping**: `macros/generate_schema_name.sql` overrides dbt's default
  so `+schema: staging` / `+schema: data_mart` write to those exact datasets
  (instead of `dev_staging`, etc.).
- **Cost control**: `stg_transactions` resolves a cut-off date once (via
  `run_query`) and injects it as a literal, so BigQuery prunes on the
  `block_timestamp_month` partition column and only ~3 months of partitions are
  scanned — well within the free tier.
- **Frozen source**: the public `crypto_bitcoin_cash` dataset is no longer
  updated (latest data ~May 2024). The 3-month window is therefore anchored on
  `max(block_timestamp_month)` in the source, not on today's date — otherwise the
  result would be empty.
- **Coinbase exclusion**: addresses appearing in any `is_coinbase = true`
  transaction output are removed from `address_balances`.
- **Balance scope**: because staging is limited to 3 months, the balance is a
  net balance over that window (documented trade-off imposed by the free-tier
  constraint).
