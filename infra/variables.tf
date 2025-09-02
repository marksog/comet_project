
variable "project_name" {
  description = "The name of the project."
  type        = string
  default = "hello-world-eks"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "A list of public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "private_subnet_cidrs" {
  description = "A list of private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "eks_version" {
  description = "The version of EKS to use."
  type        = string
  default     = "1.28"
}

variable "node_instance_type" {
  description = "The instance type for the EKS worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "ecr_repo_name" {
  description = "The name of the ECR repository."
  type        = string
  default     = "hello-world"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "hello-world-cluster"
}

variable "admin_users" {
  description = "List of IAM users with admin access"
  type        = list(string)
  default     = [
    "arn:aws:iam::923214554566:user/DevAdmin",
    "arn:aws:iam::923214554566:user/devuser",
    "arn:aws:iam::923214554566:root"
  ]
}

variable "testing" {
  description = "Testing variable"
  type        = string
  default     = "test"
  
}