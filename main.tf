locals {
  description  = "Database password rotator."
  package_file = "${path.module}/build/package.zip"
}

module "rotator_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  attach_network_policy  = true
  create_package         = false
  create_role            = var.create_role
  description            = var.description
  function_name          = var.name
  lambda_role            = var.lambda_role
  local_existing_package = local.package_file
  memory_size            = 128
  runtime                = "provided.al2"
  tags                   = var.tags
  timeout                = 180
  vpc_security_group_ids = var.vpc_security_group_ids
  vpc_subnet_ids         = var.vpc_subnet_ids
}

resource "aws_iam_role_policy" "rotator_lambda" {
  name   = "secrets-manager-access"
  policy = data.aws_iam_policy_document.rotator_lambda.json
  role   = module.rotator_lambda.lambda_role_arn
}

resource "aws_lambda_permission" "allow_secrets_manager" {
  action        = "lambda:InvokeFunction"
  function_name = module.rotator_lambda.lambda_function_name
  principal     = "secretsmanager.amazonaws.com"
  statement_id  = "AllowExecutionFromSecretsManager"
}
