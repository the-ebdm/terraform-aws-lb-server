resource "aws_s3_bucket" "main" {
  bucket = "${var.id}-${replace(var.domain, ".", "")}"
}

resource "aws_iam_role" "role" {
  name = "${var.id}-${replace(var.domain, ".", "")}-role"
  assume_role_policy = jsonencode(
    { "Version" : "2012-10-17", "Statement" : [
      {
        "Action" : "sts:AssumeRole", "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
      ]
    }
  )
  tags = { tag-key = "tag-value" }
}

resource "aws_iam_role_policy" "policy" {
  name = "${var.id}-${replace(var.domain, ".", "")}-policy"
  role = aws_iam_role.role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "s3:*"
          ],
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:s3:::${aws_s3_bucket.main.bucket}/",
            "arn:aws:s3:::${aws_s3_bucket.main.bucket}/*"
          ]
        }
      ]
    }
  )
}