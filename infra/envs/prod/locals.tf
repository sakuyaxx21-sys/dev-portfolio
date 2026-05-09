locals {
  name_prefix = "${var.env}-${var.project}"

  common_tags = {
    Project   = var.project
    Env       = var.env
    ManagedBy = "Terraform"
  }
}