variable "aws_region" {
    type = string
    description = "The AWS region you want your region-specific resources provisioned in."
    default = "us-east-1"
}

variable "resource_name_prefix" {
    type = string
    description = "all of your resources will have their identifiers prefixed with this string, so you can tell them apart."
    default = "bt"
}
