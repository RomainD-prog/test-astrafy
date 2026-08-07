# ---------------------------------------------------------------------------
# Service account used by dbt (locally and in CI)
# ---------------------------------------------------------------------------
resource "google_service_account" "dbt" {
  project      = google_project.this.project_id
  account_id   = var.dbt_service_account_id
  display_name = "dbt / CI runner"
  description  = "Runs dbt models against BigQuery (staging + data mart)."

  depends_on = [google_project_service.services]
}

# Ability to run BigQuery jobs (queries) in the project.
resource "google_project_iam_member" "dbt_job_user" {
  project = google_project.this.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.dbt.email}"
}

# Read/write access on the staging dataset only (least privilege).
resource "google_bigquery_dataset_iam_member" "dbt_staging_editor" {
  project    = google_project.this.project_id
  dataset_id = google_bigquery_dataset.staging.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.dbt.email}"
}

# Read/write access on the data mart dataset only.
resource "google_bigquery_dataset_iam_member" "dbt_data_mart_editor" {
  project    = google_project.this.project_id
  dataset_id = google_bigquery_dataset.data_mart.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.dbt.email}"
}
