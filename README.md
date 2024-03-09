# terraform-aws-vpc-peering

Terraform module to peer two VPCs with support for Route53 Private Zone resolution.

# Usage

In order to support cross-region/cross-account VPC peering, this module makes use of alternative provider names. If both
VPC exist in the same account and region, then the following will be sufficient.

```hcl
module "peer" {
  source           = "rgrizzell/vpc-peering/aws"
  requestor_vpc_id = aws_vpc.alpha.id
  acceptor_vpc_id  = aws_vpc.beta.id
  providers = {
    aws.requestor = aws
    aws.acceptor  = aws
  }
}
```

## DNS Resolution

For cases where it's desirable to be able to resolve DNS records in the peered VPC's Route53 private zone, associations
can be established. Take for instance, a backend application in a separate region that has both a Public and Private IP.
```text
Private: backend.east.example.com (CNAME) --> ip-172-16-10-10.ec2.internal             (A) --> 172.16.10.10
Public:  backend.east.example.com (CNAME) --> ec2-3-226-98-152.compute-1.amazonaws.com (A) --> 3.226.98.152
```
Without the Route53 Zone Associations, a host in a peered VPC will only resolve the Public IP.
```text
backend.east.example.com (CNAME) --> ec2-3-226-98-152.compute-1.amazonaws.com (A) --> 3.226.98.152
```
When those Route53 Zone Associations are in place, the peered VPC's host will resolve to the private IP, ensuring
traffic flows over the VPC peering connection.
```text
backend.east.example.com (CNAME) --> ip-172-16-10-10.ec2.internal (A) --> 172.16.10.10
```

However, for this to work both VPCs must first have DNS support enabled.
```hcl
resource "aws_vpc" "requestor" {
  cidr_block           = "10.0.10.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_vpc" "acceptor" {
  cidr_block           = "10.0.20.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

When it is enabled, establishing the VPC zone associations can be done by providing the Zone IDs.
```hcl
module "peer" {
  source                    = "rgrizzell/vpc-peering/aws"
  requestor_vpc_id          = aws_vpc.east.id
  acceptor_vpc_id           = aws_vpc.west.id
  requestor_private_zone_id = aws_route53_zone.east.zone_id
  acceptor_private_zone_id  = aws_route53_zone.west.zone_id
  providers = {
    aws.requestor = aws.east
    aws.acceptor  = aws.west
  }
}
```


# Known Issues
If your VPC is associated with the Private Zone using the `vpc {}` block, this may cause perpetual changes.
```text
  # aws_route53_zone.alpha_private will be updated in-place
  ~ resource "aws_route53_zone" "alpha_private" {
        id                  = "Z1111112222233333333"
        name                = "alpha.terraform.local"
        tags                = {}
        # (7 unchanged attributes hidden)

      - vpc {
          - vpc_id     = "vpc-0000011111222" -> null
          - vpc_region = "us-east-2" -> null
        }

        # (1 unchanged block hidden)
    }
```

Update the Private Zone resource to ignore VPC changes.
```hcl
resource "aws_route53_zone" "alpha_private" {
  name = "alpha.terraform.local"
  vpc {
    vpc_id = aws_vpc.alpha.id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
}
```
