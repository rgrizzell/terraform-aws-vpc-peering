# Separate Accounts with Route53 Private Zone Resolution

```hcl
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
```
