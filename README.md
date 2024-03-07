# terraform-aws-vpc-peering

Terraform module to peer two VPCs with support for Route53 Private Zone resolution.

## DNS Resolution
For cases where it's desirable to be able to resolve DNS records in the peered VPC's Private Zone, ensure that the both
VPCs have DNS support enabled.

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
