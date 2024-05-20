output "aws_api_gateway_rest_api_id" {
  value       = aws_api_gateway_rest_api.this.id
  description = "ID of the REST API"
}

output "aws_api_gateway_rest_api_root_resource_id" {
  value       = aws_api_gateway_rest_api.this.root_resource_id
  description = "Resource ID of the REST API's root"
}

output "aws_api_gateway_stage_id" {
  value       = aws_api_gateway_stage.this.id
  description = "ID of the stage"
}

output "aws_api_gateway_stage_arn" {
  value       = aws_api_gateway_stage.this.arn
  description = "ARN of the stage"
}

output "aws_api_gateway_stage_invoke_url" {
  value       = aws_api_gateway_stage.this.invoke_url
  description = "URL to invoke the API pointing to the stage, e.g., https://z4675bid1j.execute-api.eu-west-2.amazonaws.com/prod"
}

output "aws_api_gateway_stage_execution_arn" {
  value       = aws_api_gateway_stage.this.execution_arn
  description = "Execution ARN to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function, e.g., arn:aws:execute-api:eu-west-2:123456789012:z4675bid1j/prod"
}

output "api_gateway_access_log_group_arn" {
  description = "The Amazon Resource Name (ARN) specifying the log group. Any :* suffix added by the API, denoting all CloudWatch Log Streams under the CloudWatch Log Group, is removed for greater compatibility with other AWS services that do not accept the suffix."
  value       = var.api_gateway_stage_access_log_enable ? aws_cloudwatch_log_group.api_gateway_access_log[0].arn : null
}
output "integration_resource_ids" {
  value       = { for idx, integration in aws_api_gateway_resource.integration_resources : idx => integration.id }
  description = "Resource's identifier."
}

output "integration_resource_paths" {
  value       = { for idx, integration in aws_api_gateway_resource.integration_resources : idx => integration.path }
  description = " Complete path for this API resource, including all parent paths."
}

#############################
## Deployment
#############################

output "api_gateway_deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = aws_api_gateway_deployment.this.id
}

#############################
## API policy
#############################

output "api_gateway_policy_id" {
  description = "ID of the API Gateway policy"
  value       = var.api_gateway_policy != null ? aws_api_gateway_rest_api_policy.this[0].id : null
}

#############################
## Custom Domain
#############################

output "api_gateway_domain_name" {
  description = "API Gateway custom domain name"
  value       = var.create_custom_domain != false ? aws_api_gateway_domain_name.this[0].domain_name : null
}

output "api_gateway_base_path_mapping_id" {
  description = "ID of the API Gateway base path mapping"
  value       = var.create_custom_domain != false ? aws_api_gateway_base_path_mapping.this[0].id : null
}

#############################
## Authorizer 
#############################

output "api_gateway_authorizer_id" {
  description = "ID of the API Gateway authorizer"
  value       = var.create_authorizer == true ? aws_api_gateway_authorizer.this[0].id : null
}

output "api_gateway_authorizer_lambda_arn" {
  description = "ARN of the Lambda function used for API Gateway authorizer"
  value       = var.create_authorizer == true && var.authorizer_type == "TOKEN" ? aws_api_gateway_authorizer.this[0].authorizer_uri : null
}
