provider "aws" {
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "default"
  region                   = "us-west-2"
}

terraform {
  backend "s3" {
    bucket                  = "aitac-automation-tf"
    key                     = "terraform.instance.tfstate"
    region                  = "us-west-2"
    shared_credentials_file = "$HOME/.aws/credentials"
    profile                 = "default"
    encrypt                 = true
  }
  required_providers {
    aws = ">= 4.0"
  }
}

