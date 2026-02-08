terraform {
    backend "s3" {
        bucket = "akash-sre-terraform-state-backend"
        key = "sre-aws-terraform/terraform.tfstate"
        region = "ap-south-1"
        dynamodb_table = "terraform-locks"
        encrypt = true
    }
}