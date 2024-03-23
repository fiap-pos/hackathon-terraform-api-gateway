data "aws_lb" "ponto_lb" {
  name = var.ponto_nlb_name
}

# --- ponto nlb VPC link ---

resource "aws_api_gateway_vpc_link" "ponto_vpc_link" {
  name        = "tech-challenge-ponto-vpc-link"
  target_arns = [data.aws_lb.ponto_lb.arn]
}

# --- ponto API configuration ---

resource "aws_api_gateway_resource" "ponto_resource" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = "ponto"
}

resource "aws_api_gateway_resource" "ponto_proxy" {
  rest_api_id = var.api_gateway_id
  parent_id   = aws_api_gateway_resource.ponto_resource.id
  path_part   = "{proxy+}"

  depends_on = [ aws_api_gateway_resource.ponto_resource ]
}

resource "aws_api_gateway_method" "ponto_any"  {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.ponto_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }

  depends_on = [ aws_api_gateway_resource.ponto_proxy ]
}

resource "aws_api_gateway_integration" "ponto_integration" {

  http_method = aws_api_gateway_method.ponto_any.http_method
  resource_id = aws_api_gateway_resource.ponto_proxy.id
  rest_api_id = var.api_gateway_id

  type                    = "HTTP_PROXY"  
  integration_http_method = "ANY"
  uri                     = "http://${data.aws_lb.ponto_lb.dns_name}/{proxy}"

  timeout_milliseconds = 29000
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.ponto_vpc_link.id

  depends_on = [ aws_api_gateway_method.ponto_any ]
}