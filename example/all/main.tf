module "example1" {
  source           = "../"
  api_gateway_name = "test.example.ai"

  create_custom_domain = true
  custom_domain_name   = "test.example.ai"
  certificate_arn      = "arn:aws:acm:us-east-1:1234567890101:certificate/1234567-0f29-40a9-a916-abcdef123456"

  environment = "dev"
  stage_name  = "v1"
  endpoint_configuration = {
    types = ["EDGE"]
  }

  create_authorizer      = true
  authorizer_name        = "lambda-auth"
  authorizer_lambda_name = "auth-test" ## to create lambda authorizer - define existing lambda name 
  authorizer_type        = "TOKEN"

  api_gateway_stage_access_log_enable = true
  api_gateway_stage_access_log_level  = "ERROR"
  integrations = [
    {
      integration_type        = "AWS_PROXY"
      uri                     = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-central-1:1234567890101:function:users/invocations"
      lambda_name             = "users"
      http_method             = "GET"
      integration_http_method = "POST"
      path_part               = "user"
      authorization           = "CUSTOM"
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
      authorization = "CUSTOM"
    },
    {
      integration_type     = "MOCK"
      http_method          = "GET"
      path_part            = "mock"
      timeout_milliseconds = 22000
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

module "example2" {
  source           = "../"
  api_gateway_name = "api"

  environment = "dev"
  stage_name  = "v1"

  endpoint_configuration = {
    types = ["REGIONAL"]
  }

  api_gateway_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action   = "execute-api:Invoke"
        Resource = module.example2.aws_api_gateway_rest_api_arn
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" = "123.123.123.123/32"
          }
        }
      }
    ]
  })
  integrations = [
    {
      integration_type        = "AWS_PROXY"
      uri                     = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-central-1:1234567890101:function:get_users/invocations"
      http_method             = "GET"
      integration_http_method = "POST"
      path_part               = "user"
    }
  ]
}

module "example3" {
  source           = "../"
  api_gateway_name = "api"

  environment = "dev"
  stage_name  = "v1"

  endpoint_configuration = {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = ["vpce-abcdef1234567", "vpce-1234567abcdef"]
  }

  integrations = [
    {
      integration_type        = "AWS_PROXY"
      uri                     = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-central-1:1234567890101:function:get_users/invocations"
      http_method             = "GET"
      integration_http_method = "POST"
      path_part               = "user"
    }
  ]
}

module "example4" {
  source           = "../"
  api_gateway_name = "api"

  environment = "dev"
  stage_name  = "v1"

  endpoint_configuration = {
    types = ["EDGE"]
  }

  create_authorizer        = true
  authorizer_name          = "cognito-auth"
  authorizer_type          = "COGNITO_USER_POOLS"
  authorizer_provider_arns = ["arn:aws:cognito-idp:eu-central-1:1234567890101:userpool/eu-central-1_ABDDEF123"]

  integrations = [
    {
      integration_type        = "AWS_PROXY"
      uri                     = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-central-1:1234567890101:function:get_users/invocations"
      http_method             = "GET"
      integration_http_method = "POST"
      path_part               = "user"
      authorization           = "COGNITO_USER_POOLS"
    }
  ]
}