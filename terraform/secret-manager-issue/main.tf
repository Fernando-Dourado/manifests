#
terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
    }
  }
  backend "s3" {
    bucket = "fd-tf-state-321"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

provider "harness" {
  endpoint         = "https://qa.harness.io"
  account_id       = var.harness_account_id
  platform_api_key = var.harness_api_key
}

resource "harness_platform_connector_github" "ghFD_Manifests" {
  identifier       = "ghFD_Manifests_123"
  name             = "ghFD_Manifests"
  org_id      = var.org_id
  project_id  = var.project_id
  url              = "https://github.com/Fernando-Dourado/manifests"
  connection_type  = "Repo"
  delegate_selectors = ["zeaak-eks-cdplay-del-qa"]
  credentials {
    http {
      username  = "Fernando-Dourado"
      token_ref = "gh_fd_pat"
    }
  }
  api_authentication {
    token_ref = "gh_fd_pat"
  }
}
