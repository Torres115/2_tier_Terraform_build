provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "Nando_vpc" {
  source                    = "git::https://github.com/Coalfire-CF/terraform-aws-vpc-nfw.git?ref=v3.0.0"
  vpc_name                  = "Nando_vpc"
  cidr                      = "10.1.0.0/16"

  azs = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]

  subnets = [
    {
      tag               = "Mgt"
      cidr              = "10.1.0.0/24"
      type              = "public"
      availability_zone = "us-east-2a"
    },
    {
      tag               = "APP"
      cidr              = "10.1.1.0/24"
      type              = "private"
      availability_zone = "us-east-2a"
    },    
    {
      tag               = "BKE"
      cidr              = "10.1.2.0/24"
      type              = "private"
      availability_zone = "us-east-2b"
    }
  ]
  single_nat_gateway     = false
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true


  flow_log_destination_type              = "cloud-watch-logs"
  cloudwatch_log_group_retention_in_days = 30
}
