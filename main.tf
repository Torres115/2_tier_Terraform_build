provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc_minimal" {
  source = "git::https://github.com/Coalfire-CF/terraform-aws-vpc-nfw.git?ref=v3.0.0"

  vpc_name                  = "Nandos_VPC"
  cidr                      = "10.1.0.0/16"
  flow_log_destination_type = "cloud-watch-logs"

  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]
  ]

  subnets = [
    {
      tag               = "management"
      cidr              = "10.1.0.0/24"
      type              = "public"
      availability_zone = data.aws_availability_zones.available.names[0]
    },
    {
      tag               = "application"
      cidr              = "10.1.1.0/24"
      type              = "private"
      availability_zone = data.aws_availability_zones.available.names[0]
    },
    {
      tag               = "backend"
      cidr              = "10.1.2.0/24"
      type              = "private"
      availability_zone = data.aws_availability_zones.available.names[1]
    }
  ]
}

output "vpc_id" {
  value = module.vpc_minimal.vpc_id
}

output "subnets" {
  value = module.vpc_minimal.subnets
}
