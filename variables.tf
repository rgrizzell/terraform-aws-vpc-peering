variable "requestor_vpc_id" {
  type        = string
  description = "The VPC ID of the requesting peer."
}

variable "acceptor_vpc_id" {
  type        = string
  description = "The VPC ID of the accepting peer."
}

variable "requestor_private_zone_id" {
  type        = string
  description = "The private zone ID of the requesting peer VPC."
  default     = null
}

variable "acceptor_private_zone_id" {
  type        = string
  description = "The private zone ID of the accepting peer VPC."
  default     = null
}

variable "requestor_private_zone_name" {
  type        = string
  description = "The private zone name of the requesting peer VPC."
  default     = null
}

variable "acceptor_private_zone_name" {
  type        = string
  description = "The private zone name of the accepting peer VPC."
  default     = null
}

variable "auto_accept_peering" {
  type        = bool
  description = "Whether or not to automatically accept the peering request from the requestor VPC."
  default     = true
}

variable "tags" {
  default     = {}
  description = "Tags to apply to the peering connection"
  type        = map(string)
}
