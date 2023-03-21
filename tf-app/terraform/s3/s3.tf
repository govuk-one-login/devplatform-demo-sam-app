resource "aws_s3_bucket" "state" {
  bucket        = "di-devplatform-state-bucket"
  force_destroy = var.force_destroy

  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration
    ]
  }
}

data "aws_iam_policy_document" "bootstrap_bucket" {
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.state.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_acl" "state" {
  bucket = aws_s3_bucket.state.id
  acl    = "private"
}

# resource "aws_s3_bucket_versioning" "state" {
#   bucket = aws_s3_bucket.state.id

#   versioning_configuration {
#     status = var.versioning
#   }
# }

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "di-devplatform-state-bucket-development-table"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}

# resource "aws_iam_role" "deployment" {
#   name               = "role-name"
#   assume_role_policy = data.aws_iam_policy_document.trust_policy.json
# }

# resource "aws_iam_role_policy_attachment" "shared_services_deployment" {
#   role       = aws_iam_role.deployment.name
#   policy_arn = data.aws_iam_policy.deployment.arn
# }