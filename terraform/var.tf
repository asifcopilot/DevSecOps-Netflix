# Declare variables
variable "environment" {
  default = "devops-netflix"
  # description = "Name of the environment | dev | qa | prod"
}

variable "prefix" {
  default = "netflix-clone"
}

variable location {
  default = "East US"
}

variable vm_size {
  default = "Standard_B2s"
}

variable "virtualnetwork" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable subnet {
  type    = list(string)
  default = ["10.0.2.0/24"]
}


variable admin-password {
  default = "Ptiger@12"
}


