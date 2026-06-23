# ============================================================
# Root Terragrunt konfiguracija
# Svi moduli ispod nasledjuju ovo preko "include"
# Definise backend (S3) i AWS provider na JEDNOM mestu (DRY)
# ============================================================

locals {
  aws_region   = "eu-central-1"
  state_bucket = "jovan-vukasinovic-platform-terraform-state"
  lock_table   = "terraform-locks"
}

# ---- Remote state: S3 backend se generise automatski ----
# Terragrunt sam pravi key na osnovu putanje foldera (path_relative_to_include).
# Tako vpc/ ide u .../vpc/terraform.tfstate, rds/ u .../rds/terraform.tfstate.
remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = local.state_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = local.lock_table
    encrypt        = true
  }
}

# ---- AWS provider se generise automatski ----
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<PROVIDER
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      Project   = "platform"
      ManagedBy = "terragrunt"
      Repo      = "platform-bootstrap"
    }
  }
}
PROVIDER
}
