# ============================
# Common
# ============================
variable "name_prefix" {
  description = "Name prefix for network resources"
  type        = string
}

# ============================
# VPC
# ============================
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

# ============================
# Availability Zones
# ============================
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

# ============================
# Subnets
# ============================
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private db subnets"
  type        = list(string)
}

# ============================
# NAT Gateway
# ============================
variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create"
  type        = number
}

# ============================
# Application
# ============================
variable "app_port" {
  description = "Application port"
  type        = number
}
