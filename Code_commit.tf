resource "aws_codecommit_repository" "harsh-viradia-wildrydes" {
  repository_name = "harsh-viradia-wildrydes"
  tags = {
    "Name" = "Harsh-Viradia"
    "Owner" = "harsh.viradia@intuitive.cloud"
  }
}