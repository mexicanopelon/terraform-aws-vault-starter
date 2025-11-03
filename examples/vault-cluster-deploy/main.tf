provider "aws" {
  # your AWS region
  region = "us-east-1"
}

module "vault-sso" {
  source = "git@github.com:mexicanopelon/terraform-aws-vault-starter.git?ref=bessemer"

  public_subnet_ids = []


  allowed_inbound_cidrs_lb        = ["10.0.0.0/8"]
  allowed_inbound_cidrs_ssh       = [
                                      "10.204.95.130/32", 
                                      "10.201.81.39/32", 
                                      "10.242.81.42/32", 
                                      "10.242.52.196/32" 
                                    ]
  additional_lb_target_groups     = []
  common_tags                     = { 
                                      "bt:application": "HCP Vault",
                                      "bt:department": "IT - Servers",
                                      # "bt:name": "",                  // Add this directoy to the code
                                      "bt:owner": "Brett Faller",
                                      "bt:backup": "yes",
                                    }
  instance_type                   = "m5.large"
  # key_name                        = null
  # kms_key_deletion_window         = 7
  leader_tls_servername           = "vault.bessemer.com"
  lb_certificate_arn              = "??????????????"
  # lb_deregistration_delay         = "300"
  # lb_health_check_path            = "/v1/sys/health?activecode=200&standbycode=200&sealedcode=200&uninitcode=200"
  lb_type                         = "application"
  lb_internal                     = true
  node_count                      = 3
  # permissions_boundary            = null
  private_subnet_ids              = [
                                      "subnet-06c6a786e1556e91f",
                                      "subnet-0c473f95ad9680e33",
                                      "subnet-c9a71393"
                                    ]

  resource_name_prefix            = "bt"
  secrets_manager_arn             = "?????????????"
  # ssl_policy                      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  user_supplied_ami_id            = "ami-07b2bf8f104c72b1a"
  # user_supplied_iam_role_name     = null
  # user_supplied_kms_key_arn       = null
  # user_supplied_userdata_path     = null
  vault_version                   = "1.21.0"
  vpc_id                          = "vpc-5adc6023"

}