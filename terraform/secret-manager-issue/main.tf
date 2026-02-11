#
terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
    }
  }
}

provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = var.harness_account_id
  platform_api_key = var.harness_api_key
}

resource "harness_platform_service" "service_remote_template" {
  identifier  = "service_remote_template"
  name        = "service-remote-template.yaml"
  org_id      = "var.org_id"
  project_id  = "var.project_id"
  git_details {
    branch         = "main"
    commit_message = "tf apply service creation"
    file_path      = ".harness/service-remote-template.yaml"
    connector_ref  = "FD_Manifests"
    store_type     = "REMOTE"
    repo_name      = "manifests"
  }
}
