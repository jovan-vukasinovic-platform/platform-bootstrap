# ============================================================
# EKS modul.
# dependency "vpc" cita outpute vec deploy-ovanog VPC unita iz njegovog statea,
# pa subnet ID-jeve ne moramo da hardkodujemo.
# ============================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/jovan-vukasinovic-platform/terraform-modules.git//modules/eks?ref=main"
}

dependency "vpc" {
  config_path = "../vpc"

  # Mock vrednosti se koriste samo za validate; plan/apply zahtevaju stvarno deploy-ovan VPC
  mock_outputs = {
    private_subnet_ids = ["subnet-mock-a", "subnet-mock-b"]
  }
  mock_outputs_allowed_terraform_commands = ["validate"]
}

inputs = {
  name            = "platform-eks"
  cluster_version = "1.35"

  # Control plane ENI-ji i nodovi u privatnim subnetima (zahteva ukljucen NAT gateway!)
  subnet_ids = dependency.vpc.outputs.private_subnet_ids

  instance_types = ["c7i-flex.large"]
  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "SPOT"
  desired_size   = 2
  min_size       = 1
  max_size       = 3

  # ARN mog IAM usera
  admin_principal_arns = [
    "arn:aws:iam::563683519712:user/admin"
  ]

  tags = {
    Environment = "dev"
  }
}
