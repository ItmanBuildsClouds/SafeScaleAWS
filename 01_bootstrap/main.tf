# ==================================================
# == 1. Github User Role
# ==================================================

data "aws_iam_policy_document" "git_actions_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::907253920314:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = ["repo:ItmanBuildsClouds/SafeScaleAWS:ref:refs/heads/test/cicd2",
                "repo:ItmanBuildsClouds/SafeScaleAWS:pull_request"]
    }
    condition {
      test = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = ["sts.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.git_actions_trust_policy.json
}

data "aws_iam_policy_document" "github_actions_policy_remote_state" {
  statement {
    sid = "S3Remote"
    actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::safescale-aws-md25rd",
                 "arn:aws:s3:::safescale-aws-md25rd/*"]
  }
  statement {
    sid = "DynamoDBRemote"
    actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:eu-central-1:907253920314:table/safescale-aws-LockID"]
  }
}

data "aws_iam_policy_document" "github_actions_allperm" {
  statement {
    sid = "AllPermissionsforCICDTest"
    actions = ["*"]
    resources = ["*"]
  }
}



resource "aws_iam_policy" "github_actions_policy_remote_state" {
  name = "github-actions-remote-state"
  policy = data.aws_iam_policy_document.github_actions_policy_remote_state.json
}

resource "aws_iam_policy" "github_actions_policy_allperm" {
  name = "github-actions-allperm"
  policy = data.aws_iam_policy_document.github_actions_allperm.json
}



resource "aws_iam_policy_attachment" "github_actions_policy_remote_state_attach" {
    name = "github-actions-policy-remote-state"
    policy_arn = aws_iam_policy.github_actions_policy_remote_state.arn
    roles = [aws_iam_role.github_actions_role.name]
}


resource "aws_iam_policy_attachment" "github_actions_policy_allperm_attach" {
    name = "github-actions-policy-allperm"
    policy_arn = aws_iam_policy.github_actions_policy_allperm.arn
    roles = [aws_iam_role.github_actions_role.name]
}