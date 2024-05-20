variable "integrations" {
  description = "List of API Gateway integrations"
  type = list(object({
    integration_type        = string
    lambda_name             = optional(string, null)
    http_method             = string
    integration_http_method = optional(string, null)
    path_part               = string
    uri                     = optional(string, null)
    timeout_milliseconds    = optional(number, 29000)
    request_parameters      = optional(map(string), {})
    request_templates       = optional(map(string), {})
    passthrough_behavior    = optional(string, null)
    content_handling        = optional(string, null)
    authorization           = optional(string, "NONE")
  }))
  default = []
}

variable "api_gateway_name" {
  type        = string
  description = "API gateway name"
}

variable "custom_domain_name" {
  type        = string
  default     = null
  description = "API gateway custom domain name"
}

variable "custom_domain_base_path" {
  type        = string
  default     = null
  description = "A custom path for custom domain mapping, e.g. default behaviour https://api.example.com/v1 -> https://api.example.com, or if defined https://api.example.com/v1 -> https://api.example.com/v1"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "stage_name" {
  type        = string
  description = "Name of the stage, will be used here: https://api.example.com/{stage_name}/*"
}

variable "create_custom_domain" {
  type        = bool
  default     = false
  description = "Determines a custom domain name for use with AWS API Gateway"
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "ARN for an AWS-managed certificate. AWS Certificate Manager is the only supported source, required only if create_custom_domain is set to true"
}

variable "endpoint_configuration" {
  default     = null
  description = "Configuration block defining API endpoint configuration including endpoint type."
}

variable "minimum_compression_size" {
  type        = number
  default     = -1
  description = "Minimum response size to compress for the REST API. String containing an integer value between -1 and 10485760"
}

variable "fail_on_warnings" {
  type        = bool
  default     = false
  description = "Whether warnings while API Gateway is creating or updating the resource should return an error or not"
}

variable "rest_api_parameters" {
  type        = map(any)
  default     = null
  description = "Map of customizations for importing the specification in the body argument"
}

variable "put_rest_api_mode" {
  type        = string
  default     = "merge"
  description = "Mode of the PutRestApi operation when importing an OpenAPI specification via the body argument (create or update operation). Valid values are merge and overwrite"
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Key-value map of api gateway tags"
}

variable "api_gateway_policy" {
  type        = string
  default     = null
  description = "API Gateway REST API Policy, here you can restrict access to the API gateway. Documentation: https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-resource-policies.html"
}

variable "api_gateway_stage_access_log_enable" {
  type        = bool
  default     = false
  description = "Enables access logs for the API stage"
}

variable "api_gateway_stage_access_log_format" {
  type        = string
  default     = "{\"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\",\"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
  description = "The access log format for API Gateway"
}

variable "api_gateway_stage_access_log_level" {
  type        = string
  default     = "OFF"
  description = "Logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs. The available levels are OFF, ERROR, and INFO."
}

variable "api_gateway_stage_access_log_method" {
  type        = string
  default     = "*/*"
  description = "Method path defined as {resource_path}/{http_method} for an individual method override, or */* for overriding all methods in the stage."
}

variable "api_gateway_stage_access_log_data_trace_enable" {
  type        = bool
  default     = false
  description = "Whether data trace logging is enabled for this method, which effects the log entries pushed to Amazon CloudWatch Logs"
}

variable "authorizer_name" {
  type        = string
  default     = null
  description = "Name of the authorizer to create"
}

variable "create_authorizer" {
  type        = bool
  default     = false
  description = "Determines create API gateway authoriser or not"
}

variable "authorizer_lambda_name" {
  type        = string
  default     = null
  description = "Lambda name of existing lambda authorizer"
}
variable "authorizer_type" {
  default     = "TOKEN"
  description = "(Optional) Type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO_USER_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN."
}
variable "authorizer_provider_arns" {
  type        = list(string)
  default     = []
  description = "(Optional, required for authorizer_type COGNITO_USER_POOLS) List of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account_id}:userpool/{user_pool_id}."
}
variable "authorizer_identity_source" {
  default     = "method.request.header.Authorization"
  description = "Source of the identity in an incoming request. Defaults to method.request.header.Authorization"
}
variable "authorizer_identity_validation_expression" {
  type        = string
  default     = null
  description = "(Optional) Validation expression for the incoming identity. For TOKEN type, this value should be a regular expression. The incoming token from the client is matched against this expression, and will proceed if the token matches. If the token doesn't match, the client receives a 401 Unauthorized response."
}

variable "authorizer_result_ttl_in_seconds" {
  type        = number
  default     = 300
  description = "TTL of cached authorizer results in seconds. Defaults to 300."
}
