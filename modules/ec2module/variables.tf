variable instancetype {
  type        = string
  description = "set aws instance type"
  default     = "t2.nano"
}

variable sg_name {
  type        = string
  description = "set sg name "
  default     = "endy-sg"
}

variable "policy_arns" {
  default = "arn:aws:iam::aws:policy/AdministratorAccess"
  type        = string
  description = "ARN of policy to be associated with the created IAM user"
}

variable aws_common_tag {
  type        = map
  description = "Set aws tag"
  default = {
    Name = "ec2-endy"
  }
}

variable tf_users{
    type = set(string)
    description = "Terraform users"
    default = ["endy-test-user-1", "endy-test-user-2", "endy-test-user-3"]
}