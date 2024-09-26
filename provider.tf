terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  shared_config_files = ["C:/Users/r.ali/.aws/config"]
  shared_credentials_files = ["C:/Users/r.ali/.aws/credentials"]
  profile = "ml-reply"
}
