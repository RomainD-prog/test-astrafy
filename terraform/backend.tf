# State backend.
#
# Default = LOCAL backend: the state is stored on disk in `terraform.tfstate`
# (git-ignored). This keeps the take-home simple and avoids depending on a
# cross-project state bucket.
#
# To use a remote GCS backend instead, uncomment the block below, create the
# bucket first (see `bootstrap/`), then run:
#   terraform init -reconfigure -backend-config="bucket=<your-state-bucket>"
#
# terraform {
#   backend "gcs" {
#     prefix = "crypto-bitcoin-cash/terraform/state"
#   }
# }
