# ---------------------------------------------------------------------------
# Workload Identity Federation for GitHub Actions
# Lets the GitHub Actions workflow impersonate the dbt service account
# WITHOUT any long-lived JSON key.
# ---------------------------------------------------------------------------
resource "google_iam_workload_identity_pool" "github" {
  project                   = google_project.this.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions pool"
  description               = "Identity pool for GitHub Actions OIDC tokens."

  depends_on = [google_project_service.services]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = google_project.this.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  # Only tokens coming from the expected repository are accepted.
  attribute_condition = "assertion.repository == \"${var.github_repository}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Allow the GitHub repo (via the pool) to impersonate the dbt service account.
resource "google_service_account_iam_member" "dbt_wif_user" {
  service_account_id = google_service_account.dbt.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"
}
