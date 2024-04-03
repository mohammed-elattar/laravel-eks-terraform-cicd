resource "aws_ecr_repository" "ecr_repo" {
  name = "craftscene-php"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_repo_2" {
  name = "craftscene-nginx"
  image_scanning_configuration {
    scan_on_push = true
  }
}
