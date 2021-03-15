resource "aws_iam_role" "iam_for_lambda_tf" {
  name = "iam_for_lambda_tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_policy" {
  depends_on = ["aws_iam_role.iam_for_lambda_tf"]
  name       = "s3_policy"
  role       = "${aws_iam_role.iam_for_lambda_tf.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetBucketLocation",
              "s3:ListBucket",
              "s3:ListAllMyBuckets"
          ],
          "Resource": [
              "arn:aws:s3:::*"
          ]
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:PutObject",
              "s3:GetObject"
          ],
          "Resource": [
              "arn:aws:s3:::webstack-env-*"

          ]
      }
  ]
}
EOF
}