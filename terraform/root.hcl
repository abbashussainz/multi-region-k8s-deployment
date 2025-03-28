remote_state {
  backend = "s3"
  config = {
    bucket         = "machine-test-march"
    key            = "${path_relative_to_include()}/terraform.tfstate"  # One state file per environment
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}