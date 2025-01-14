data "aws_ami" "Ubuntu22ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vprofile-bastion" {
  ami                    = data.aws_ami.Ubuntu22ami.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.vprofilekey.key_name
  subnet_id              = module.vpc.public_subnets[0]
  count                  = var.instance_count
  vpc_security_group_ids = [aws_security_group.vprofile-bastion-sg.id]

  tags = {
    Name    = "vprofile-bastion"
    MangeBy = "Terraform"
    Project = "vprofile"
  }

  # terraform provisioner can execute scripts on the instance in this Our RDS instance gets created when we execute this Terraform code,So our RDS endpoint the username, the password.
  # These things are dynamic for us.We need to mention all this in our script, When we write our script, we need to mention that this is no MySQL RDS endpoint.
  # The RDS endpoint username all that we need to mention and that we want Terraform to automatically find.

  # we want to have a script that is dynamic that will fetch the value automatically. 
  # And for that we can use a concept called templates in Terraform.
  # We can use a template file to write a script that is dynamic.

  provisioner "file" {
    source      = templatefile("templates/db-deploy.tmpl", { rds_endpoint = aws_db_instance.vprofile-rds.address, dbuser = var.dbuser, dbpass = var.dbpass })
    destination = "/tmp/vprofile-db-deploy.sh"
  }

  connection {
    type        = "ssh"
    user        = var.USERNAME
    private_key = file(var.PRIV_KEY_PATH)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vprofile-db-deploy.sh",
      "/tmp/vprofile-db-deploy.sh"
    ]

  }
}