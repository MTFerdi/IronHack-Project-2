terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "mtferdi-ironhack-tfstate"           # your bucket in ca-west-1
    key            = "envs/dev/terraform.tfstate"
    region         = "ca-west-1"
    dynamodb_table = "ferdinando-ironhack-project-1-tflock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.53"
    }
  }
}
