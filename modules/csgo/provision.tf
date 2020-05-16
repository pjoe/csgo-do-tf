data "template_file" "install" {
  template = file("${path.module}/files/install.sh")

  vars = {
    admin_ips = join(" ", var.admin_ips)
  }
}

data "template_file" "setup" {
  for_each = var.config

  template = file("${path.module}/files/setup.sh")

  vars = {
    gslt_token     = each.value.gslt_token
    mysql_password = "DONT USE"
  }
}

data "template_file" "csgoserver_cfg" {
  for_each = var.config

  template = file("${path.module}/files/cfg/csgoserver.cfg")

  vars = {
    gslt_token = each.value.gslt_token
    ip         = digitalocean_droplet.csgo[each.key].ipv4_address
  }
}

data "template_file" "server_cfg" {
  for_each = var.config

  template = file("${path.module}/files/cfg/server.cfg")

  vars = {
    server_name   = each.value.server_name
    server_passwd = each.value.server_password
    rcon_passwd   = each.value.rcon_password
    ip            = digitalocean_droplet.csgo[each.key].ipv4_address
  }
}

data "template_file" "docker_compose" {
  for_each = var.config

  template = file("${path.module}/files/docker-compose.yml")

  vars = {
    server_name    = each.value.server_name
    ip             = digitalocean_droplet.csgo[each.key].ipv4_address
    mysql_password = "DONT USE"
  }
}

resource "null_resource" "csgoserver-install" {
  for_each = var.config

  triggers = {
    #   rerun = uuid()
    instance = digitalocean_droplet.csgo[each.key].id
    install  = data.template_file.install.rendered
  }

  depends_on = [
    digitalocean_droplet.csgo,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_key)
    host        = digitalocean_droplet.csgo[each.key].ipv4_address
  }

  provisioner "file" {
    destination = "/tmp/install.sh"
    content     = data.template_file.install.rendered
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh"
    ]
  }
}

resource "null_resource" "csgoserver-setup" {
  for_each = var.config

  triggers = {
    #   rerun = uuid()
    instance                        = digitalocean_droplet.csgo[each.key].id
    install                         = data.template_file.install.rendered
    setup                           = data.template_file.setup[each.key].rendered
    csgoserver_cfg                  = data.template_file.csgoserver_cfg[each.key].rendered
    server_cfg                      = data.template_file.server_cfg[each.key].rendered
    gamemode_competitive_server_cfg = file("${path.module}/files/cfg/gamemode_competitive_server.cfg")
    botprofile_db                   = file("${path.module}/files/botprofile.db")
    docker_compose                  = data.template_file.docker_compose[each.key].rendered
  }

  depends_on = [
    digitalocean_droplet.csgo,
    null_resource.csgoserver-install,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_key)
    host        = digitalocean_droplet.csgo[each.key].ipv4_address
  }

  provisioner "file" {
    destination = "/home/csgoserver/lgsm/config-lgsm/csgoserver/csgoserver.cfg"
    content     = data.template_file.csgoserver_cfg[each.key].rendered
  }

  provisioner "file" {
    destination = "/home/csgoserver/serverfiles/csgo/cfg/csgoserver.cfg"
    content     = data.template_file.server_cfg[each.key].rendered
  }

  provisioner "file" {
    destination = "/home/csgoserver/serverfiles/csgo/cfg/gamemode_competitive_server.cfg"
    source      = "${path.module}/files/cfg/gamemode_competitive_server.cfg"
  }

  provisioner "file" {
    destination = "/home/csgoserver/serverfiles/csgo/botprofile.db"
    source      = "${path.module}/files/botprofile.db"
  }

  provisioner "file" {
    destination = "/home/csgoserver/docker-compose.yml"
    content     = data.template_file.docker_compose[each.key].rendered
  }

  provisioner "file" {
    destination = "/tmp/setup.sh"
    content     = data.template_file.setup[each.key].rendered
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh"
    ]
  }

}
