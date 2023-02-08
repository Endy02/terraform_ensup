provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA5HPA5JMVRY56EB5G"
  secret_key = "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"
}

terraform {
  backend "s3" {
    bucket = "backend-endy"
    encrypt = true
    key    = "endy.tfstate"
    region = "us-east-1"
    access_key = "AKIA5HPA5JMVRY56EB5G"
    secret_key = "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"
  }
}

module "ec2" {
  source = "../modules/ec2module"
  instancetype = "t2.micro"
  aws_common_tag = {
    Name = "ec2-endy"
  }
  sg_name = "endy-sg"
}
