data "template_file" "install" {
  template = "${file("${path.module}/install.sh")}"

  vars = {
    admin_ip = "${var.admin_ip}"
  }
}

data "template_file" "setup" {
  template = "${file("${path.module}/setup.sh")}"

  vars = {
    gslt_token = "${var.gslt_token}"
  }
}

data "template_file" "csgoserver_cfg" {
  template = "${file("${path.module}/cfg/csgoserver.cfg")}"

  vars = {
    gslt_token = "${var.gslt_token}"
    ip         = "${digitalocean_droplet.csgo.ipv4_address}"
  }
}

data "template_file" "server_cfg" {
  template = "${file("${path.module}/cfg/server.cfg")}"

  vars = {
    server_name   = "${var.server_name}"
    server_passwd = "${var.server_password}"
    rcon_passwd   = "${var.rcon_password}"
    ip            = "${digitalocean_droplet.csgo.ipv4_address}"
  }
}

data "template_file" "docker_compose" {
  template = "${file("${path.module}/docker/docker-compose.yml")}"

  vars = {
    server_name    = "${var.server_name}"
    ip             = "${digitalocean_droplet.csgo.ipv4_address}"
    mysql_password = "${var.mysql_password}"
  }
}

resource "null_resource" "csgoserver-install" {
  triggers {
    #   rerun = "${uuid()}"
    instance = "${digitalocean_droplet.csgo.id}"
    install  = "${data.template_file.install.rendered}"
  }

  depends_on = [
    "digitalocean_droplet.csgo",
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key)}"
    host        = "${digitalocean_droplet.csgo.ipv4_address}"
  }

  provisioner "remote-exec" {
    inline = <<EOF
${data.template_file.install.rendered}
EOF
  }
}

resource "null_resource" "csgoserver-setup" {
  triggers {
    #   rerun = "${uuid()}"
    instance                        = "${digitalocean_droplet.csgo.id}"
    install                         = "${data.template_file.install.rendered}"
    setup                           = "${file("${path.module}/setup.sh")}"
    csgoserver_cfg                  = "${data.template_file.csgoserver_cfg.rendered}"
    server_cfg                      = "${data.template_file.server_cfg.rendered}"
    gamemode_competitive_server_cfg = "${file("${path.module}/cfg/gamemode_competitive_server.cfg")}"
    docker_compose                  = "${data.template_file.docker_compose.rendered}"
  }

  depends_on = [
    "digitalocean_droplet.csgo",
    "null_resource.csgoserver-install",
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key)}"
    host        = "${digitalocean_droplet.csgo.ipv4_address}"
  }

  provisioner "file" {
    destination = "/home/csgoserver/lgsm/config-lgsm/csgoserver/csgoserver.cfg"
    content     = "${data.template_file.csgoserver_cfg.rendered}"
  }

  provisioner "file" {
    destination = "/home/csgoserver/serverfiles/csgo/cfg/csgoserver.cfg"
    content     = "${data.template_file.server_cfg.rendered}"
  }

  provisioner "file" {
    destination = "/home/csgoserver/serverfiles/csgo/cfg/gamemode_competitive_server.cfg"
    source      = "cfg/gamemode_competitive_server.cfg"
  }

  provisioner "file" {
    destination = "/home/csgoserver/docker-compose.yml"
    content     = "${data.template_file.docker_compose.rendered}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/setup.sh"
  }
}
