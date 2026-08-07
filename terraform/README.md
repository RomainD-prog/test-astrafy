# Terraform — GCP infrastructure

Provisions everything the coding challenge requires, **entirely via IaC**:

- a **new Google Cloud project** (`google_project`);
- the required BigQuery **datasets**: `staging` and `data_mart`;
- a **service account** (`dbt-runner`) with least-privilege BigQuery permissions;
- **Workload Identity Federation** so GitHub Actions can authenticate without a key.

## Files

| File | Purpose |
|---|---|
| `versions.tf` | Provider + Terraform version constraints |
| `backend.tf` | Remote state in GCS (bucket passed at init time) |
| `variables.tf` | Input variables |
| `main.tf` | Project creation + API enablement |
| `bigquery.tf` | `staging` and `data_mart` datasets |
| `iam.tf` | Service account + BigQuery roles |
| `wif.tf` | Workload Identity Federation for GitHub Actions |
| `outputs.tf` | Values needed for dbt + GitHub secrets |
| `bootstrap/` | Creates the GCS bucket holding the remote state |

## Prerequisites

- `terraform >= 1.5`, `gcloud` CLI authenticated (`gcloud auth application-default login`).
- A **billing account** and an **org or folder** where the project can be created.
- An existing **seed project** to host the state bucket (used by `bootstrap/`).

## Usage

### 1. Create the state bucket (once)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # fill in seed project + bucket name
terraform init
terraform apply
```

### 2. Provision the main infrastructure

```bash
cd ..
cp terraform.tfvars.example terraform.tfvars   # fill in project_id, billing_account, org/folder, github_repository
terraform init -backend-config="bucket=<state-bucket-from-step-1>"
terraform plan
terraform apply
```

### 3. Grab the outputs (for dbt + GitHub)

```bash
terraform output
```

- `project_id` → export as `DBT_PROJECT_ID` locally and set as GitHub **variable** `GCP_PROJECT_ID`.
- `dbt_service_account_email` → GitHub **secret** `GCP_SERVICE_ACCOUNT`.
- `workload_identity_provider` → GitHub **secret** `GCP_WORKLOAD_IDENTITY_PROVIDER`.

## Notes

- **Least privilege**: the service account gets `bigquery.jobUser` at project level (to run queries) and `bigquery.dataEditor` **only** on the two datasets. Reading `bigquery-public-data` needs no extra grant (public datasets are world-readable).
- **No manual resources**: every cloud resource used by the challenge is declared here. Nothing is created by hand.
- **Free tier**: dbt only scans the last 3 months (partition-pruned), staying within the BigQuery free tier.
