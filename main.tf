#############################
## API GW
#############################
resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_gateway_name
  description = "${var.api_gateway_name} ${var.environment} API gateway"

  dynamic "endpoint_configuration" {
    for_each = var.endpoint_configuration != null ? [var.endpoint_configuration] : []
    content {
      types = endpoint_configuration.value.types
      vpc_endpoint_ids = contains(endpoint_configuration.value.types, "PRIVATE") ? endpoint_configuration.value.vpc_endpoint_ids : null
    }
  }
  minimum_compression_size = var.minimum_compression_size
  fail_on_warnings         = var.fail_on_warnings

  parameters = var.rest_api_parameters

  put_rest_api_mode = "merge"
  tags = merge(
    var.tags,
    { Name = "${var.api_gateway_name}-api-gateway" }
  )
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name

  dynamic "access_log_settings" {
    for_each = var.api_gateway_stage_access_log_enable == true ? [var.api_gateway_stage_access_log_enable] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway_access_log[0].arn
      format          = var.api_gateway_stage_access_log_format
    }
  }
  tags = merge(
    var.tags,
    { Name = "${var.api_gateway_name}-api-gateway-stage" }
  )
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = var.api_gateway_stage_access_log_enable
    logging_level      = var.api_gateway_stage_access_log_level
    data_trace_enabled = var.api_gateway_stage_access_log_data_trace_enable
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_access_log" {
  count             = var.api_gateway_stage_access_log_enable == true ? 1 : 0
  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.this.name}-access-logs"
  retention_in_days = 7
  tags = merge(
    var.tags,
    { Name = "${var.api_gateway_name}-api-gateway-log-group" }
  )
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  depends_on = [
    aws_api_gateway_method.integration_methods,
    aws_api_gateway_integration.this
  ]
  description = "${var.api_gateway_name} ${var.environment} deployment"

  triggers = {
    always_run = "${timestamp()}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#############################
## API policy
#############################

resource "aws_api_gateway_rest_api_policy" "this" {
  count       = var.api_gateway_policy != null ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = var.api_gateway_policy
}

#############################
## Integrations
#############################

resource "aws_api_gateway_resource" "integration_resources" {
  for_each    = { for idx, integration in var.integrations : idx => integration }
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path_part
}

resource "aws_api_gateway_method" "integration_methods" {
  for_each    = { for idx, integration in var.integrations : idx => integration }
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.integration_resources[each.key].id
  http_method = each.value.http_method

  authorization = lookup(each.value, "authorization", "NONE")
  authorizer_id = var.create_authorizer && var.authorizer_type != "NONE" ? aws_api_gateway_authorizer.this[0].id : null
}

resource "aws_api_gateway_integration" "this" {
  for_each                = { for idx, integration in var.integrations : idx => integration }
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.integration_resources[each.key].id
  http_method             = aws_api_gateway_method.integration_methods[each.key].http_method
  integration_http_method = lookup(each.value, "integration_http_method", null)

  type = each.value.integration_type
  uri  = lookup(each.value, "uri", null)

  request_parameters   = lookup(each.value, "request_parameters", {})
  request_templates    = lookup(each.value, "request_templates", {})
  passthrough_behavior = lookup(each.value, "passthrough_behavior", null)
  content_handling     = lookup(each.value, "content_handling", null)
  timeout_milliseconds = lookup(each.value, "timeout_milliseconds", 29000)

  connection_type = lookup(each.value, "connection_type", null)
  connection_id   = lookup(each.value, "connection_id", null)
}

resource "aws_api_gateway_method_response" "integration_method_responses" {
  for_each    = { for idx, integration in var.integrations : idx => integration }
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.integration_resources[each.key].id
  http_method = aws_api_gateway_method.integration_methods[each.key].http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "integration_integration_responses" {
  for_each    = { for idx, integration in var.integrations : idx => integration }
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.integration_resources[each.key].id
  http_method = aws_api_gateway_method.integration_methods[each.key].http_method
  status_code = aws_api_gateway_method_response.integration_method_responses[each.key].status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_domain_name" "this" {
  count           = var.create_custom_domain != false ? 1 : 0
  certificate_arn = var.certificate_arn
  domain_name     = var.custom_domain_name
  tags = merge(
    var.tags,
    { Name = "${var.api_gateway_name}-api-gateway-domain-name" }
  )
}

resource "aws_api_gateway_base_path_mapping" "this" {
  count       = var.create_custom_domain != false ? 1 : 0
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.this[0].domain_name
  base_path   = var.custom_domain_base_path
}

#############################
## Authorizer 
#############################

resource "aws_api_gateway_authorizer" "this" {
  count = var.create_authorizer == true ? 1 : 0

  name                             = var.authorizer_name
  rest_api_id                      = aws_api_gateway_rest_api.this.id
  authorizer_credentials           = aws_iam_role.invocation_role[0].arn
  identity_source                  = var.authorizer_identity_source
  type                             = var.authorizer_type
  authorizer_result_ttl_in_seconds = var.authorizer_result_ttl_in_seconds
  identity_validation_expression   = var.authorizer_identity_validation_expression
  authorizer_uri                   = var.authorizer_type == "TOKEN" ? "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.authorizer_lambda_name}/invocations" : null
  provider_arns                    = var.authorizer_type == "COGNITO_USER_POOLS" ? var.authorizer_provider_arns : []
}

resource "aws_iam_role" "invocation_role" {
  count = var.create_authorizer == true ? 1 : 0

  name               = "${var.api_gateway_name}-${var.environment}-authorizer-invocation-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role[0].json
  tags = merge(
    var.tags,
    { Name = "${var.api_gateway_name}-api-gateway-role" }
  )
}

data "aws_iam_policy_document" "invocation_assume_role" {
  count = var.create_authorizer == true ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "invocation_policy" {
  count = var.create_authorizer == true && var.authorizer_type == "TOKEN" ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.authorizer_lambda_name}"]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  count = var.create_authorizer == true && var.authorizer_type == "TOKEN" ? 1 : 0

  name   = "allow-lambda-auth-invocation"
  role   = aws_iam_role.invocation_role[0].id
  policy = data.aws_iam_policy_document.invocation_policy[0].json

}