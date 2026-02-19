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
      token_ref = "GH_PAT_for_FernandoD_on_AWS"
    }
  }
  api_authentication {
    token_ref = "GH_PAT_for_FernandoD_on_AWS"
  }
}

resource "harness_platform_service" "service_remote_template" {
  identifier  = "service_remote_template"
  name        = "service-remote-template"
  org_id      = var.org_id
  project_id  = var.project_id
  import_from_git = "true"
  git_details {
    branch         = "main"
    commit_message = "tf apply service creation"
    file_path      = ".harness/service-remote-template.yaml"
    connector_ref  = "ghFD_Manifests_123"
    store_type     = "REMOTE"
    repo_name      = "manifests"
  }
  depends_on = [harness_platform_connector_github.ghFD_Manifests]
}

resource "harness_platform_pipeline" "tf_sm_issue" {
  identifier 	= "Terraform_Secret_Manager_Issue"
  org_id      	= var.org_id
  project_id  	= var.project_id
  name       	= "Terraform Secret Manager Issue"
  yaml = <<-EOT
	pipeline:
	  name: Terraform Secret Manager Issue
	  identifier: Terraform_Secret_Manager_Issue
	  projectIdentifier: FernandoD
	  orgIdentifier: default
	  tags: {}
	  stages:
	    - stage:
	        name: TF
	        identifier: TF
	        description: ""
	        type: CI
	        spec:
	          cloneCodebase: false
	          caching:
	            enabled: true
	            override: true
	            paths: []
	          buildIntelligence:
	            enabled: true
	          execution:
	            steps:
	              - step:
	                  type: GitClone
	                  name: Clone
	                  identifier: Clone
	                  spec:
	                    connectorRef: ghFD_Manifests_123
	                    build:
	                      type: branch
	                      spec:
	                        branch: main
	              - step:
	                  type: Run
	                  name: Init
	                  identifier: Init
	                  spec:
	                    connectorRef: Public_Docker_Hub
	                    image: hashicorp/terraform:1.11.4
	                    shell: Sh
	                    command: |-
	                      echo "tfenv use 1.11.4 <DISABLED>"

	                      cd /harness/manifests/terraform/secret-manager-issue
	                      echo "Terraform Execution starts"
	                      ls -l

	                      terraform init -reconfigure \
	                        -backend-config="access_key=<+pipeline.variables.AWS_ACCESS_KEY>" \
	                        -backend-config="secret_key=<+pipeline.variables.AWS_SECRET_KEY>"
	              - step:
	                  type: Run
	                  name: Plan
	                  identifier: Plan
	                  spec:
	                    connectorRef: Public_Docker_Hub
	                    image: hashicorp/terraform:1.11.4
	                    shell: Sh
	                    command: |-
	                      cd /harness/manifests/terraform/secret-manager-issue

	                      terraform plan \
	                        -var=harness_account_id=zEaak-FLS425IEO7OLzMUg \
	                        -var=harness_api_key=<+pipeline.variables.apiKey> \
	                        -var-file=./terraform.tfvars
	                  when:
	                    stageStatus: Success
	                    condition: "false"
	              - step:
	                  type: Run
	                  name: Apply
	                  identifier: Apply
	                  spec:
	                    connectorRef: Public_Docker_Hub
	                    image: hashicorp/terraform:1.11.4
	                    shell: Sh
	                    command: |-
	                      cd /harness/manifests/terraform/secret-manager-issue

	                      #export TF_LOG=DEBUG

	                      terraform apply -auto-approve \
	                        -var=harness_account_id=zEaak-FLS425IEO7OLzMUg \
	                        -var=harness_api_key=<+pipeline.variables.apiKey> \
	                        -var-file=./terraform.tfvars
	          infrastructure:
	            type: KubernetesDirect
	            spec:
	              connectorRef: fdcluster
	              namespace: harness-delegate-ng
	              automountServiceAccountToken: true
	              nodeSelector: {}
	              os: Linux
	        delegateSelectors:
	          - cv-cg-test-delegate
	  variables:
	    - name: apiKey
	      type: Secret
	      description: ""
	      required: false
	      value: FernandoD_TF_Token
	    - name: AWS_SECRET_KEY
	      type: Secret
	      description: ""
	      required: false
	      value: CD_Play_--_Admin_Secret_Key
	    - name: AWS_ACCESS_KEY
	      type: Secret
	      description: ""
	      required: false
	      value: CD_Play_--_Admin_Access_Key
	  delegateSelectors:
	    - cv-cg-test-delegate
  EOT
  depends_on = [harness_platform_connector_github.ghFD_Manifests]
}
