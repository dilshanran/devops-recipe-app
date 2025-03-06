terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.0"
    }
  }

  backend "s3" {
    bucket               = "devops-app-recipe-state"
    key                  = "tf-state-deploy"
    workspace_key_prefix = "tf-state-deploy-env" # This is the prefix for the workspace
    region               = "us-east-1"
    encrypt              = true
    dynamodb_table       = "devops-recipe-app-api-tflock"

  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "Environment" = terraform.workspace
      Project       = var.project
      contact       = var.contact
      ManagedBy     = "Terraform/deploy"
    }
  }
}

locals {
  prefix = "${var.prefix}-${terraform.workspace}"
}

data "aws_region" "current" {
}
