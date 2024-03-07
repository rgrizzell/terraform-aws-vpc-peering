module "peer" {
  #source           = "rgrizzell/vpc-peering/aws"
  source           = "../../"
  requestor_vpc_id = aws_vpc.alpha.id
  acceptor_vpc_id  = aws_vpc.beta.id
  providers = {
    aws.requestor = aws
    aws.acceptor  = aws
  }
}



provider "aws" {
  region = "us-east-2"
}
resource "aws_vpc" "alpha" {
  cidr_block = "172.16.0.0/16"
}
resource "aws_vpc" "beta" {
  cidr_block = "172.17.0.0/16"
}
