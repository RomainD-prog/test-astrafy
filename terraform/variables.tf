variable "project_id" {
  description = "ID of the Google Cloud project to CREATE (must be globally unique)."
  type        = string
}

variable "project_name" {
  description = "Human-friendly display name for the project."
  type        = string
  default     = "Crypto Bitcoin Cash Analytics"
}

variable "billing_account" {
  description = "Billing account ID to attach to the new project (format XXXXXX-XXXXXX-XXXXXX)."
  type        = string
}

variable "org_id" {
  description = "Organization ID under which to create the project. Leave empty if using folder_id."
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "Folder ID under which to create the project. Takes precedence over org_id if both set."
  type        = string
  default     = ""
}

variable "region" {
  description = "Default region for the provider."
  type        = string
  default     = "europe-west1"
}

variable "bq_location" {
  description = "BigQuery datasets location. Must match the source public dataset (crypto_bitcoin_cash lives in US)."
  type        = string
  default     = "US"
}

variable "staging_dataset_id" {
  description = "BigQuery dataset ID for staging tables."
  type        = string
  default     = "staging"
}

variable "data_mart_dataset_id" {
  description = "BigQuery dataset ID for data mart tables."
  type        = string
  default     = "data_mart"
}

variable "dbt_service_account_id" {
  description = "Account ID (prefix) of the service account used by dbt / CI."
  type        = string
  default     = "dbt-runner"
}

variable "github_repository" {
  description = "GitHub repository allowed to impersonate the service account via WIF (format: owner/repo)."
  type        = string
}

variable "gcp_services" {
  description = "Google Cloud APIs to enable on the project."
  type        = list(string)
  default = [
    "bigquery.googleapis.com",
    "bigquerystorage.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
  ]
}
