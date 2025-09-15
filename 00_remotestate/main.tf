resource "random_string" "suffix" {
    length = 6
    special = false
    upper = false
}

resource "aws_s3_bucket" "s3_remote_state" {
    bucket = "${var.project_name}-${random_string.suffix.result}"

    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "s3_remote_state_pab" {
    bucket = aws_s3_bucket.s3_remote_state.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_remote_state_versioning" {
    bucket = aws_s3_bucket.s3_remote_state.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_remote_state_encryption" {
    bucket = aws_s3_bucket.s3_remote_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_dynamodb_table" "dynamodb_remote_state" {
    name = "${var.project_name}-LockID"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}

