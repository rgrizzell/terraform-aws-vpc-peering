module "peer" {
  #source                    = "rgrizzell/vpc-peering/aws"
  source                    = "../../"
  requestor_vpc_id          = aws_vpc.east.id
  acceptor_vpc_id           = aws_vpc.west.id
  requestor_private_zone_id = aws_route53_zone.east.zone_id
  acceptor_private_zone_id  = aws_route53_zone.west.zone_id
  providers = {
    aws.requestor = aws.east
    aws.acceptor  = aws.west
  }
}



// East
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}
resource "aws_vpc" "east" {
  provider             = aws.east
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
resource "aws_route53_zone" "east" {
  provider = aws.east
  name     = "east.terraform.local"
  vpc {
    vpc_id = aws_vpc.east.id
  }
}
resource "aws_route53_record" "east_alice" {
  provider = aws.east
  name     = "alice"
  records  = ["172.16.0.10"]
  type     = "A"
  zone_id  = aws_route53_zone.east.zone_id
}

// West
provider "aws" {
  alias  = "west"
  region = "us-west-1"
}
resource "aws_vpc" "west" {
  provider             = aws.west
  cidr_block           = "172.17.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
resource "aws_route53_zone" "west" {
  provider = aws.west
  name     = "west.terraform.local"
  vpc {
    vpc_id = aws_vpc.west.id
  }
}
resource "aws_route53_record" "west_bob" {
  provider = aws.west
  name     = "bob"
  records  = ["172.17.0.20"]
  type     = "A"
  zone_id  = aws_route53_zone.west.zone_id
}
