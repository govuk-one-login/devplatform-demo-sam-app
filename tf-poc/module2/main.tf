resource "aws_dynamodb_table" "some_table" {
  name           = "plat-1105-table"
  hash_key       = "LockID"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
