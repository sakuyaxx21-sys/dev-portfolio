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
# Public Subnets
# ============================
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

# ============================
# Private App Subnets
# ============================
variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets"
  type        = list(string)
}

# ============================
# Private DB Subnets
# ============================
variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private db subnets"
  type        = list(string)
}

# ============================
# Application
# ============================
variable "app_port" {
  description = "Application port"
  type        = number
}