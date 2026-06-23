# ============================================================
# VPC modul.
# include "root" povlaci backend + provider iz root.hcl.
# terraform.source pokazuje na modul u terraform-modules repou.
# inputs = vrednosti koje se prosledjuju modulu (kao module {} blok u TF-u).
# ============================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/jovan-vukasinovic-platform/terraform-modules.git//modules/vpc?ref=v1.1.0"
}

inputs = {
  name     = "platform"
  vpc_cidr = "10.0.0.0/16"

  azs = ["eu-central-1a", "eu-central-1b"]

  public_subnet_cidrs  = ["10.0.0.0/20", "10.0.16.0/20"]
  private_subnet_cidrs = ["10.0.32.0/20", "10.0.48.0/20"]

  enable_nat_gateway = false

  tags = {
    Environment = "dev"
  }
}
