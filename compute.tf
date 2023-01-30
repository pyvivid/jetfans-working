resource "random_id" "mtc_node_id" {
  byte_length = 2
  count       = var.main_instance_count
}

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "mtc_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "mtc_main" {
  count                  = var.main_instance_count
  instance_type          = var.main_instance_type # value coming in from the variables.tf file
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg_pub.id]
  subnet_id              = aws_subnet.mtc_public_subnet[count.index].id
  # user_data              = templatefile("./user-data.tpl", { new_hostname = "mtc_main-${random_id.mtc_node_id[count.index].dec}" })
  root_block_device {
    volume_size = var.main_vol_size # vol size is by default in Gibi bytes.
  }
  tags = {
    Name = "mtc_main-${random_id.mtc_node_id[count.index].dec}"
  }
  provisioner "local-exec" {
    # make sure the file is created, to ensure the information is captured.
    command = "echo '\n${self.public_ip}' >> aws_hosts" ## && aws ec2 wait instance-status-ok --instance-ids ${self.id} --region us-west-2
  }
  provisioner "local-exec" {
    when    = destroy
    command = "sed -i '/^[0-9]/d' aws_hosts"
  }
}

/* resource "null_resource" "jaje_install" {
    depends_on = [aws_instance.mtc_main]
    provisioner "local-exec"{
      command = "ansible-playbook -i aws_hosts --key-file ~/.ssh/mtc_key plays/main-playbook.yml"
    }
} */

/* resource "null_resource" "grafana_update" {
  count = var.main_instance_count
  provisioner "remote-exec" {
    inline = ["sudo apt upgrade -y grafana && touch upgrade.log && echo 'Grafana is updated' >> upgrade.log"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/g004_vvdcloud/.ssh/mtckey")
      host        = aws_instance.mtc_main[count.index].public_ip
    }
  }
} */