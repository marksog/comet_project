

terraform {
  backend "s3" {
    bucket         = "comethelloworldstorage"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "comethelloworldstorage"
    encrypt        = true
  }
}