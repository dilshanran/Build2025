terraform {
  backend "s3" {
    bucket = "terraformbackendbucket0801"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}
