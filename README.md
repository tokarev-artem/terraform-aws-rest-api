# AWS REST API gateway module

# Example usage:
```hcl
  module "api" {
    source  = "tokarev-artem/rest-api/aws"

    api_gateway_name = "api"

    environment = "dev"
    stage_name  = "v1"

    endpoint_configuration = {
      types = ["EDGE"]
    }

    integrations = [
      {
        integration_type        = "AWS_PROXY"
        uri                     = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-central-1:123456789101:function:get_users/invocations"
        http_method             = "GET"
        integration_http_method = "POST"
        path_part               = "user"
      },
      {
        integration_type        = "HTTP"
        uri                     = "https://google.com/"
        http_method             = "GET"
        integration_http_method = "GET"
        path_part               = "group"
        request_parameters = {
          "integration.request.header.X-Authorization" = "'static'"
          "integration.request.header.X-Foo"           = "'Bar'"
        }
        request_templates = {
          "application/json" = ""
          "application/xml"  = "#set($inputRoot = $input.path('$'))\n{ }"
        }
        passthrough_behavior = "WHEN_NO_MATCH"
        content_handling     = "CONVERT_TO_TEXT"
        authorization        = "CUSTOM"
      },
      {
        integration_type     = "MOCK"
        http_method          = "GET"
        path_part            = "mock"
        request_parameters = {
          "integration.request.header.X-Authorization" = "'static'"
        }
        request_templates = {
          "application/xml" = <<EOF
      {
        "body" : $input.json('$')
      }
            EOF
        }
      }
    ]
  }
```



## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_access_log_group_arn"></a> [api\_gateway\_access\_log\_group\_arn](#output\_api\_gateway\_access\_log\_group\_arn) | The Amazon Resource Name (ARN) specifying the log group. Any :* suffix added by the API, denoting all CloudWatch Log Streams under the CloudWatch Log Group, is removed for greater compatibility with other AWS services that do not accept the suffix. |
| <a name="output_api_gateway_authorizer_id"></a> [api\_gateway\_authorizer\_id](#output\_api\_gateway\_authorizer\_id) | ID of the API Gateway authorizer |
| <a name="output_api_gateway_authorizer_lambda_arn"></a> [api\_gateway\_authorizer\_lambda\_arn](#output\_api\_gateway\_authorizer\_lambda\_arn) | ARN of the Lambda function used for API Gateway authorizer |
| <a name="output_api_gateway_base_path_mapping_id"></a> [api\_gateway\_base\_path\_mapping\_id](#output\_api\_gateway\_base\_path\_mapping\_id) | ID of the API Gateway base path mapping |
| <a name="output_api_gateway_deployment_id"></a> [api\_gateway\_deployment\_id](#output\_api\_gateway\_deployment\_id) | ID of the API Gateway deployment |
| <a name="output_api_gateway_domain_name"></a> [api\_gateway\_domain\_name](#output\_api\_gateway\_domain\_name) | API Gateway custom domain name |
| <a name="output_api_gateway_policy_id"></a> [api\_gateway\_policy\_id](#output\_api\_gateway\_policy\_id) | ID of the API Gateway policy |
| <a name="output_aws_api_gateway_rest_api_id"></a> [aws\_api\_gateway\_rest\_api\_id](#output\_aws\_api\_gateway\_rest\_api\_id) | ID of the REST API |
| <a name="output_aws_api_gateway_rest_api_root_resource_id"></a> [aws\_api\_gateway\_rest\_api\_root\_resource\_id](#output\_aws\_api\_gateway\_rest\_api\_root\_resource\_id) | Resource ID of the REST API's root |
| <a name="output_aws_api_gateway_stage_arn"></a> [aws\_api\_gateway\_stage\_arn](#output\_aws\_api\_gateway\_stage\_arn) | ARN of the stage |
| <a name="output_aws_api_gateway_stage_execution_arn"></a> [aws\_api\_gateway\_stage\_execution\_arn](#output\_aws\_api\_gateway\_stage\_execution\_arn) | Execution ARN to be used in lambda\_permission's source\_arn when allowing API Gateway to invoke a Lambda function, e.g., arn:aws:execute-api:eu-west-2:123456789012:z4675bid1j/prod |
| <a name="output_aws_api_gateway_stage_id"></a> [aws\_api\_gateway\_stage\_id](#output\_aws\_api\_gateway\_stage\_id) | ID of the stage |
| <a name="output_aws_api_gateway_stage_invoke_url"></a> [aws\_api\_gateway\_stage\_invoke\_url](#output\_aws\_api\_gateway\_stage\_invoke\_url) | URL to invoke the API pointing to the stage, e.g., https://z4675bid1j.execute-api.eu-west-2.amazonaws.com/prod |
| <a name="output_integration_resource_ids"></a> [integration\_resource\_ids](#output\_integration\_resource\_ids) | Resource's identifier. |
| <a name="output_integration_resource_paths"></a> [integration\_resource\_paths](#output\_integration\_resource\_paths) | Complete path for this API resource, including all parent paths. |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_gateway_name"></a> [api\_gateway\_name](#input\_api\_gateway\_name) | API gateway name | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the stage, will be used here: https://api.example.com/{stage_name}/* | `string` | n/a | yes |
| <a name="input_api_gateway_policy"></a> [api\_gateway\_policy](#input\_api\_gateway\_policy) | API Gateway REST API Policy, here you can restrict access to the API gateway. Documentation: https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-resource-policies.html | `string` | `null` | no |
| <a name="input_api_gateway_stage_access_log_data_trace_enable"></a> [api\_gateway\_stage\_access\_log\_data\_trace\_enable](#input\_api\_gateway\_stage\_access\_log\_data\_trace\_enable) | Whether data trace logging is enabled for this method, which effects the log entries pushed to Amazon CloudWatch Logs | `bool` | `false` | no |
| <a name="input_api_gateway_stage_access_log_enable"></a> [api\_gateway\_stage\_access\_log\_enable](#input\_api\_gateway\_stage\_access\_log\_enable) | Enables access logs for the API stage | `bool` | `false` | no |
| <a name="input_api_gateway_stage_access_log_format"></a> [api\_gateway\_stage\_access\_log\_format](#input\_api\_gateway\_stage\_access\_log\_format) | The access log format for API Gateway | `string` | `"{\"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\",\"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"` | no |
| <a name="input_api_gateway_stage_access_log_level"></a> [api\_gateway\_stage\_access\_log\_level](#input\_api\_gateway\_stage\_access\_log\_level) | Logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs. The available levels are OFF, ERROR, and INFO. | `string` | `"OFF"` | no |
| <a name="input_api_gateway_stage_access_log_method"></a> [api\_gateway\_stage\_access\_log\_method](#input\_api\_gateway\_stage\_access\_log\_method) | Method path defined as {resource\_path}/{http\_method} for an individual method override, or */* for overriding all methods in the stage. | `string` | `"*/*"` | no |
| <a name="input_authorizer_identity_source"></a> [authorizer\_identity\_source](#input\_authorizer\_identity\_source) | Source of the identity in an incoming request. Defaults to method.request.header.Authorization | `string` | `"method.request.header.Authorization"` | no |
| <a name="input_authorizer_identity_validation_expression"></a> [authorizer\_identity\_validation\_expression](#input\_authorizer\_identity\_validation\_expression) | (Optional) Validation expression for the incoming identity. For TOKEN type, this value should be a regular expression. The incoming token from the client is matched against this expression, and will proceed if the token matches. If the token doesn't match, the client receives a 401 Unauthorized response. | `string` | `null` | no |
| <a name="input_authorizer_lambda_name"></a> [authorizer\_lambda\_name](#input\_authorizer\_lambda\_name) | Lambda name of existing lambda authorizer | `string` | `null` | no |
| <a name="input_authorizer_name"></a> [authorizer\_name](#input\_authorizer\_name) | Name of the authorizer to create | `string` | `null` | no |
| <a name="input_authorizer_provider_arns"></a> [authorizer\_provider\_arns](#input\_authorizer\_provider\_arns) | (Optional, required for authorizer\_type COGNITO\_USER\_POOLS) List of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account\_id}:userpool/{user\_pool\_id}. | `list(string)` | `[]` | no |
| <a name="input_authorizer_result_ttl_in_seconds"></a> [authorizer\_result\_ttl\_in\_seconds](#input\_authorizer\_result\_ttl\_in\_seconds) | TTL of cached authorizer results in seconds. Defaults to 300. | `number` | `300` | no |
| <a name="input_authorizer_type"></a> [authorizer\_type](#input\_authorizer\_type) | (Optional) Type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO\_USER\_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN. | `string` | `"TOKEN"` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN for an AWS-managed certificate. AWS Certificate Manager is the only supported source, required only if create\_custom\_domain is set to true | `string` | `null` | no |
| <a name="input_create_authorizer"></a> [create\_authorizer](#input\_create\_authorizer) | Determines create API gateway authoriser or not | `bool` | `false` | no |
| <a name="input_create_custom_domain"></a> [create\_custom\_domain](#input\_create\_custom\_domain) | Determines a custom domain name for use with AWS API Gateway | `bool` | `false` | no |
| <a name="input_custom_domain_base_path"></a> [custom\_domain\_base\_path](#input\_custom\_domain\_base\_path) | A custom path for custom domain mapping, e.g. default behaviour https://api.example.com/v1 -> https://api.example.com, or if defined https://api.example.com/v1 -> https://api.example.com/v1 | `string` | `null` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | API gateway custom domain name | `string` | `null` | no |
| <a name="input_endpoint_configuration"></a> [endpoint\_configuration](#input\_endpoint\_configuration) | Configuration block defining API endpoint configuration including endpoint type. | `any` | `null` | no |
| <a name="input_fail_on_warnings"></a> [fail\_on\_warnings](#input\_fail\_on\_warnings) | Whether warnings while API Gateway is creating or updating the resource should return an error or not | `bool` | `false` | no |
| <a name="input_integrations"></a> [integrations](#input\_integrations) | List of API Gateway integrations | <pre>list(object({<br>    integration_type        = string<br>    lambda_name             = optional(string, null)<br>    http_method             = string<br>    integration_http_method = optional(string, null)<br>    path_part               = string<br>    uri                     = optional(string, null)<br>    timeout_milliseconds    = optional(number, 29000)<br>    request_parameters      = optional(map(string), {})<br>    request_templates       = optional(map(string), {})<br>    passthrough_behavior    = optional(string, null)<br>    content_handling        = optional(string, null)<br>    authorization           = optional(string, "NONE")<br>  }))</pre> | `[]` | no |
| <a name="input_minimum_compression_size"></a> [minimum\_compression\_size](#input\_minimum\_compression\_size) | Minimum response size to compress for the REST API. String containing an integer value between -1 and 10485760 | `number` | `-1` | no |
| <a name="input_put_rest_api_mode"></a> [put\_rest\_api\_mode](#input\_put\_rest\_api\_mode) | Mode of the PutRestApi operation when importing an OpenAPI specification via the body argument (create or update operation). Valid values are merge and overwrite | `string` | `"merge"` | no |
| <a name="input_rest_api_parameters"></a> [rest\_api\_parameters](#input\_rest\_api\_parameters) | Map of customizations for importing the specification in the body argument | `map(any)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of api gateway tags | `map(any)` | `{}` | no | 