output "project_id" {
  description = "ID of the created Google Cloud project."
  value       = google_project.this.project_id
}

output "project_number" {
  description = "Number of the created Google Cloud project."
  value       = google_project.this.number
}

output "staging_dataset" {
  description = "BigQuery staging dataset ID."
  value       = google_bigquery_dataset.staging.dataset_id
}

output "data_mart_dataset" {
  description = "BigQuery data mart dataset ID."
  value       = google_bigquery_dataset.data_mart.dataset_id
}

output "dbt_service_account_email" {
  description = "Email of the service account used by dbt / CI. Set as the GCP_SERVICE_ACCOUNT GitHub secret."
  value       = google_service_account.dbt.email
}

output "workload_identity_provider" {
  description = "Full resource name of the WIF provider. Set as the GCP_WORKLOAD_IDENTITY_PROVIDER GitHub secret."
  value       = google_iam_workload_identity_pool_provider.github.name
}
