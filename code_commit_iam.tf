resource "aws_iam_user" "harsh-viradia-code-commit" {
  name = "harsh-viradia-wildrydes"

  tags = {
    "Name" = "Harsh-Viradia"
    "Owner" = "harsh.viradia@intuitive.cloud"
  }
}

resource "aws_iam_user_policy_attachment" "harsh-viradia-policy-attachment" {
  user = aws_iam_user.harsh-viradia-code-commit.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"

}

resource "aws_iam_service_specific_credential" "harsh-viradia-git-crenditial" {
  service_name = "codecommit.amazonaws.com"
  user_name = aws_iam_user.harsh-viradia-code-commit.name
}

output "git-crenditial-user" {
  value = aws_iam_service_specific_credential.harsh-viradia-git-crenditial.service_user_name
}

output "git_crenditial-password" {
  value = nonsensitive(aws_iam_service_specific_credential.harsh-viradia-git-crenditial.service_password)
  sensitive = false
}