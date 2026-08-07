# ---------------------------------------------------------------------------
# Bootstrap: creates the GCS bucket that stores the remote Terraform state.
#
# This MUST run before `terraform init` of the main configuration, because the
# state backend needs to exist first. It uses a LOCAL backend on purpose
# (chicken-and-egg) and runs inside an already-existing "seed" project.
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.state_project_id
  region  = var.region
}

variable "state_project_id" {
  description = "Existing project that will host the Terraform state bucket."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally-unique name of the state bucket to create."
  type        = string
}

variable "region" {
  description = "Location of the state bucket."
  type        = string
  default     = "europe-west1"
}

resource "google_storage_bucket" "tf_state" {
  name                        = var.state_bucket_name
  project                     = var.state_project_id
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "state_bucket_name" {
  description = "Use this value in: terraform init -backend-config=\"bucket=<value>\""
  value       = google_storage_bucket.tf_state.name
}
