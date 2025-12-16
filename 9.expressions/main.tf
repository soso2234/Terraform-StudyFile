terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

variable "users" {
  type = list(any)
}

resource "aws_iam_group" "devs" {
  name = "devs"
}

resource "aws_iam_group" "emps" {
  name = "emps"
}

resource "aws_iam_user" "test_users" {
  for_each = tomap({
    for user in var.users : user.name => user
  })
  name = each.key

  tags = {
    Name   = each.value.name
    Role   = each.value.role
    Is_dev = each.value.is_dev
  }
}

resource "aws_iam_user_group_membership" "team" {
  for_each = tomap({
    for user in var.users : user.name => user
  })
  user = each.key

  groups = each.value.is_dev ? [aws_iam_group.devs.name, aws_iam_group.emps.name] : [aws_iam_group.emps.name]
}


//=========================================

# terraform {
#   required_providers {
#     local = {
#       source = "hashicorp/local"
#       version = "2.6.1"
#     }
#   }
# }

# provider "local" {
#   # Configuration options
# }

# variable "for_list" {
#   type = list
#   default = ["abc", "DEF", "", "gHi"]
# }

# variable "for_map" {
#   type = map
#   default = {"a":"bc", "d":"ef", "g":"hij"}
# }

# locals {
#   list_upper = [for s in var.for_list : upper(s)]
#   list_lower = [for s in var.for_list : lower(s)]
#   map_length = [for k, l in var.for_map : length(k)+length(l)]
#   list_index = [for i, v in var.for_list : "${i+1}:${v}"]
#   map_upper = {for s in var.for_list : s => upper(s)}
#   test_upper = [for s in var.for_list : upper(s) if s != ""]
# }

# output "list_upper" {
#   value = local.list_upper
# }

# output "list_lower" {
#   value = local.list_lower
# }

# output "map_length" {
#   value = local.map_length
# }

# output "list_index" {
#   value = local.list_index
# }

# output "map_upper" {
#   value = local.map_upper
# }

# output "test_upper" {
#   value = local.test_upper
# }

# variable "names" {
#   default = ["alice", "bob", "carol"]
# }

# variable "users" {
#   default = {
#     alice = "admin"
#     bob   = "user"
#   }
# }

# variable "lists" {
#   default = [[1, 2], [3, 4]]
# }

# output "flat_list" {
#   value = [for sublist in var.lists : [for v in sublist : v]]
# }

# output "upper_names" {
#   value = [for name in var.names : upper(name) if name != "bob"]
# }

# output "role_labels" {
#   value = {for name, role in var.users : name => role if role == "admin"}
# }

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "6.26.0"
#     }
#   }
# }

# provider "aws" {
#   # Configuration options
# }

# variable "igw_enable" {
#   description = "Internet gateway Install? [true/false]"
#   type        = bool
# }

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "main"
#   }
# }

# resource "aws_internet_gateway" "gw" {
#   count  = var.igw_enable ? 1 : 0
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "main"
#   }
# }