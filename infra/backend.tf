# ============================
# Terraform Backend
# ============================
terraform {
  backend "s3" {
    bucket  = "dev-portfolio-tfstate-139295583002"
    key     = "dev/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "terraform-dev"

    encrypt      = true
    use_lockfile = true
  }
}