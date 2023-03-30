resource "aws_amplify_app" "harsh-viradia-amplify" {
  name       = "harsh-viradia-net-app"
  repository = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/harsh-viradia-wildrydes"

  # The default build_spec added by the Amplify Console for React.

  build_spec = <<-EOT
version: 1
frontend:
  phases:
    build:
      commands: []
  artifacts:
    baseDirectory: /
    files:
      - '**/*'
  cache:
    paths: []
EOT

  enable_branch_auto_build = true
  iam_service_role_arn     = aws_iam_role.harsh-viradia-amplify-codecommit.arn

}

resource "aws_amplify_branch" "harsh-viradia-amplify-branch" {
  app_id      = aws_amplify_app.harsh-viradia-amplify.id
  branch_name = "master"
}

data "aws_iam_policy_document" "harsh_viradia_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "harsh-viradia-amplify-codecommit" {
  name                = "harsh-viradia-Codecommit-amplify"
  assume_role_policy  = join("", data.aws_iam_policy_document.harsh_viradia_assume_role.*.json)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"]
}
