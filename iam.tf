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
              "arn:aws:s3:::rmathi-ec2-inventory*"

          ]
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = "${aws_iam_role.iam_for_lambda_tf.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = "${aws_iam_role.iam_for_lambda_tf.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy_lambda"
  role = "${aws_iam_role.iam_for_lambda_tf.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "ec2:Get*"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "sns_policy" {
  name = "sns_policy_lambda"
  role = "${aws_iam_role.iam_for_lambda_tf.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"

      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}
