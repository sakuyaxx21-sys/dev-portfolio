terraform {
  required_version = "~> 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.61.0, < 6.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}