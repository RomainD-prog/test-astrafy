# ---------------------------------------------------------------------------
# BigQuery datasets: staging + data mart
# ---------------------------------------------------------------------------
resource "google_bigquery_dataset" "staging" {
  project     = google_project.this.project_id
  dataset_id  = var.staging_dataset_id
  location    = var.bq_location
  description = "Staging layer materialized by dbt (last 3 months of raw transactions)."

  labels = {
    layer   = "staging"
    managed = "terraform"
  }

  depends_on = [google_project_service.services]
}

resource "google_bigquery_dataset" "data_mart" {
  project     = google_project.this.project_id
  dataset_id  = var.data_mart_dataset_id
  location    = var.bq_location
  description = "Data mart layer materialized by dbt (analytics-ready tables)."

  labels = {
    layer   = "data_mart"
    managed = "terraform"
  }

  depends_on = [google_project_service.services]
}
