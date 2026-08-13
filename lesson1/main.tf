resource "random_pet" "server_name" {
  length = 3
}

resource "local_file" "hello" {
  filename = "${path.module}/hello.txt"
  content  = "[${var.env}] server name: ${random_pet.server_name.id}\n"
}

resource "local_file" "server_info" {
    filename = "${path.module}/server_info.txt"
    content = "server name: ${random_pet.server_name.id}\n"
}

variable "env" {
  type    = string
  default = "dev"
}

output "pet_name" {
  value = random_pet.server_name.id
}