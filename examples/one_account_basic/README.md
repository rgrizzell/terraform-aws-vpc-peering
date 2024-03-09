# One Account

```hcl
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
```
