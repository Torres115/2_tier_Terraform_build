provider "aws" {
  region = "us-east-2"
}

module "Nando_vpc" {
  source                    = "git::https://github.com/Coalfire-CF/terraform-aws-vpc-nfw.git?ref=v3.0.0"
  vpc_name                  = "Nando_vpc"
  cidr                      = "10.1.0.0/16"
  flow_log_destination_type = "cloud-watch-logs"

  azs = ["us-east-2a", "us-east-2b"]

  subnets = [
    { tag = "management",  cidr = "10.1.0.0/24", type = "public",  availability_zone = "us-east-2a" },
    { tag = "application", cidr = "10.1.1.0/24", type = "private", availability_zone = "us-east-2a" },
    { tag = "backend",     cidr = "10.1.2.0/24", type = "private", availability_zone = "us-east-2b" }
  ]

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true
  deploy_aws_nfw         = false
}

output "vpc_id"   { value = module.Nando_vpc.vpc_id }
output "subnets"  { value = module.Nando_vpc.subnets }
