output "s3_remote_state" {
    value = aws_s3_bucket.s3_remote_state.id
}
output "dynamodb_remote_state" {
    value = aws_dynamodb_table.dynamodb_remote_state.id
}

output "s3_remote_state_arn" {
    value = aws_s3_bucket.s3_remote_state.arn
}
output "dynamodb_remote_state_arn" {
    value = aws_dynamodb_table.dynamodb_remote_state.arn
}
