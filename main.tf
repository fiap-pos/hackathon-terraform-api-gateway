#----  API Gateway Configuration ----

resource "aws_api_gateway_rest_api" "hackathon_gw" {
  name = "hackathon-api-gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#---- ponto API configuration ----

module "ponto_api" {
  source = "./modules/ponto_api"
  api_gateway_id = aws_api_gateway_rest_api.hackathon_gw.id
  api_gateway_root_resource_id = aws_api_gateway_rest_api.hackathon_gw.root_resource_id
  ponto_nlb_name = var.ponto_nlb_name
  depends_on = [ aws_api_gateway_rest_api.hackathon_gw ]
}


#---- Api Gateway Deployment ----

resource "aws_api_gateway_deployment" "dev_stage" {
  rest_api_id = aws_api_gateway_rest_api.hackathon_gw.id
  stage_name  = "dev" 

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    module.ponto_api
  ]
}

# Outputs

output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.dev_stage.invoke_url}"
}
