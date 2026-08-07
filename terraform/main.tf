# ---------------------------------------------------------------------------
# Google Cloud project
# ---------------------------------------------------------------------------
resource "google_project" "this" {
  name            = var.project_name
  project_id      = var.project_id
  billing_account = var.billing_account

  # A project lives under an org OR a folder, not both. folder_id wins if set.
  org_id    = var.folder_id == "" ? (var.org_id == "" ? null : var.org_id) : null
  folder_id = var.folder_id == "" ? null : var.folder_id

  # Keep the state authoritative but avoid accidental deletion protection issues.
  deletion_policy = "DELETE"
}

# ---------------------------------------------------------------------------
# Enable the required APIs on the new project
# ---------------------------------------------------------------------------
resource "google_project_service" "services" {
  for_each = toset(var.gcp_services)

  project = google_project.this.project_id
  service = each.value

  # Keep APIs enabled if the resource is removed, to avoid breaking dependents.
  disable_on_destroy = false
}
