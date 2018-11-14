terraform {
  backend "s3" {
    workspace_key_prefix = "terraform_study/scenario2"
    key                  = "terraform.tfstate"
  }
}
