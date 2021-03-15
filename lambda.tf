data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/files"
  output_path = "${path.module}/files/inventory.zip"
}

resource "aws_lambda_function" "inventory" {
  function_name    = "${var.function_name}"
  handler          = "${var.handler_name}"
  filename         = "${data.archive_file.function_zip.output_path}"
  #filename         = "inventory.zip"
  description      = "EC2 Inventory"
  timeout          = "120"
  runtime          = "python3.8"
  role             = "${aws_iam_role.iam_for_lambda_tf.arn}"
  #source_code_hash = base64sha256(data.archive_file.function_zip.output_path)
  source_code_hash = "${base64sha256(file(data.archive_file.function_zip.output_path))}"
  publish          = true


  vpc_config = {
    subnet_ids         = "${var.subnet_ids}"
    security_group_ids = "${var.security_group_id}"
  }

}

