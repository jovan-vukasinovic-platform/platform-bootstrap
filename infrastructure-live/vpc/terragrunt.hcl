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
  source = "git::https://github.com/jovan-vukasinovic-platform/terraform-modules.git//modules/vpc?ref=main"
}

inputs = {
  name     = "platform"
  vpc_cidr = "10.0.0.0/16"

  azs = ["eu-central-1a", "eu-central-1b"]

  public_subnet_cidrs  = ["10.0.0.0/20", "10.0.16.0/20"]
  private_subnet_cidrs = ["10.0.32.0/20", "10.0.48.0/20"]

  # EKS nodovi zive u privatnim subnetima - NAT im je potreban za izlaz na internet
  # (povlacenje image-a, addoni, ArgoCD -> GitHub itd.)
  enable_nat_gateway = true
  single_nat_gateway = true

  # Tagovi po kojima EKS/AWS pronalazi subnete u koje sme da stavi load balancere
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = "dev"
  }
}
