variable "api_gateway_id" {
  type        = string
  description = "Id of api gateway to configure Auth api"
}

variable "api_gateway_root_resource_id" {
  type        = string
  description = "Id of api gateway root resource"
}


variable "ponto_nlb_name" {
  type    = string
  description = "Name of network load balancer to create vpc link"
}
