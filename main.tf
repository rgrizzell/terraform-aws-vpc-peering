locals {
  requestor_dns = var.requestor_private_zone_id != null || var.requestor_private_zone_name != null ? true : false
  acceptor_dns  = var.acceptor_private_zone_id != null || var.acceptor_private_zone_name != null ? true : false
}
/*
 Requestor Configuration
*/
data "aws_vpc" "requestor" {
  provider = aws.requestor
  id       = var.requestor_vpc_id
}
data "aws_route53_zone" "requestor" {
  provider = aws.requestor
  //count    = requestor_dns ? 1 : 0  TODO
  name    = var.requestor_private_zone_id == null ? var.requestor_private_zone_name : null
  zone_id = var.requestor_private_zone_id
  vpc_id  = var.requestor_private_zone_id == null ? data.aws_vpc.requestor.id : null
}

// Create the peering connection on the requesting side.
resource "aws_vpc_peering_connection" "requestor" {
  provider      = aws.requestor
  peer_owner_id = data.aws_caller_identity.acceptor.account_id
  peer_vpc_id   = data.aws_vpc.acceptor.id
  vpc_id        = data.aws_vpc.requestor.id
  requester {
    allow_remote_vpc_dns_resolution = local.requestor_dns
  }
  tags = var.tags
}

// Allow the accepting VPC to associate to the requesting VPC's private zone.
resource "aws_route53_vpc_association_authorization" "requestor" {
  provider = aws.requestor
  //count    = requestor_dns ? 1 : 0  TODO: Test
  vpc_id  = data.aws_vpc.acceptor.id
  zone_id = data.aws_route53_zone.requestor.zone_id
}

// Associate to the accepting VPC's private zone.
resource "aws_route53_zone_association" "requestor" {
  provider = aws.requestor
  //count    = requestor_dns ? 1 : 0  TODO: Test
  vpc_id  = data.aws_vpc.requestor.id
  zone_id = data.aws_route53_zone.acceptor.zone_id
}


/*
 Acceptor Configuration
*/
data "aws_caller_identity" "acceptor" {
  provider = aws.acceptor
}
data "aws_vpc" "acceptor" {
  provider = aws.acceptor
  id       = var.acceptor_vpc_id
}
data "aws_route53_zone" "acceptor" {
  provider = aws.acceptor
  //count    = acceptor_dns ? 1 : 0  TODO: Test
  name    = var.acceptor_private_zone_id == null ? var.acceptor_private_zone_name : null
  zone_id = var.acceptor_private_zone_id
  vpc_id  = var.acceptor_private_zone_id == null ? data.aws_vpc.acceptor.id : null
}

// Accepting the incoming peering connection request.
resource "aws_vpc_peering_connection_accepter" "acceptor" {
  provider                  = aws.acceptor
  auto_accept               = var.auto_accept_peering
  vpc_peering_connection_id = aws_vpc_peering_connection.requestor.id
  accepter {
    allow_remote_vpc_dns_resolution = local.acceptor_dns
  }
}

// Allow the requesting VPC to associate to the accepting VPC's private zone.
resource "aws_route53_vpc_association_authorization" "acceptor" {
  provider = aws.acceptor
  //count    = acceptor_dns ? 1 : 0  TODO: Test
  vpc_id  = data.aws_vpc.requestor.id
  zone_id = data.aws_route53_zone.acceptor.zone_id
}
// Associate to the requesting VPC's private zone.
resource "aws_route53_zone_association" "acceptor" {
  provider = aws.acceptor
  //count    = acceptor_dns ? 1 : 0  TODO: Test
  vpc_id  = data.aws_vpc.acceptor.id
  zone_id = data.aws_route53_zone.requestor.zone_id
}
