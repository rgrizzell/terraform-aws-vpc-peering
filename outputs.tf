output "id" {
  value       = aws_vpc_peering_connection.requestor.id
  description = "The ID of the VPC peering connection. It is the same for both VPCs, despite different providers."
}
