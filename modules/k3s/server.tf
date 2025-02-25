resource "null_resource" "server" {
    provisioner "remote-exec" {
        inline = [
            "curl -sfL https://get.k3s.io | sh -"
        ]
        connection {
            type        = var.connection.type
            private_key = file(var.connection.private_key)
            host        = var.connection.host
        }
    }
}