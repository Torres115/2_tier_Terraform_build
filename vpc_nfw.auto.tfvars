module "mgmt_vpc" {
  source = "git::https://github.com/Coalfire-CF/terraform-aws-vpc-nfw.git?ref=vx.x.x"
  name = "VPC_TORRES"
  cidr = "10.1.0.0/16"
  azs  = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]data.aws_availability_zones.available.names[2]]

  subnets = [
    {
      tag               = "subnet1"
      cidr              = "10.1.1.0/24"
      type              = "firewall"
      availability_zone = "us-east-1a"
    },
    {
      tag               = "subnet2"
      cidr              = "10.1.2.0/24"
      type              = "public"
      availability_zone = "us-east-1b"
    }
  {
      tag               = "subnet3"
      cidr              = "10.1.3.0/24"
      type              = "public"
      availability_zone = "us-gov-west-1b"
    }
  ]

  single_nat_gateway     = false
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true

  flow_log_destination_type              = "cloud-watch-logs"
  cloudwatch_log_group_retention_in_days = 30
  cloudwatch_log_group_kms_key_id        = "arn:aws-us-gov:kms:your-cloudwatch-kms-key-arn"

  deploy_aws_nfw                        = true
  delete_protection                     = true
  aws_nfw_prefix                        = "example"
  aws_nfw_name                          = "example-nfw"
  aws_nfw_fivetuple_stateful_rule_group = local.fivetuple_rule_group
  aws_nfw_suricata_stateful_rule_group  = local.suricata_rule_group_shrd_svcs
  nfw_kms_key_arn                        = "arn:aws-us-gov:kms:your-nfw-kms-key-arn"
}
