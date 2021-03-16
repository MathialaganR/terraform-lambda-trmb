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


resource "aws_cloudwatch_event_target" "lambda_event" {
  arn  = "${aws_lambda_function.inventory.arn}"
  rule = "${aws_cloudwatch_event_rule.lambda_rule.id}"

  input = <<JSON
{
  "Test": "False"
}
JSON

}

resource "aws_cloudwatch_event_rule" "lambda_rule" {
  name                = "lambda_rule_inventory"
  description         = "Inventory and Notification"
  schedule_expression = "cron(0 */12 * * ? *)"

}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.inventory.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.lambda_rule.arn}"
}

data "aws_lambda_invocation" "lambda_inventory_invoke" {
  function_name = "${aws_lambda_function.inventory.function_name}"

  input = <<JSON
{
  "Test": "False"
}
JSON
}