resource "aws_dynamodb_table" "harsh-viradia-db" {
  name = "harsh-viradia-wildrides-db-table"

  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key = "harshviradiaridled"

  attribute {
    name = "harshviradiaridled"
    type = "S"
  }
}