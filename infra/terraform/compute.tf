resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.main.key_name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion"
    Tier = "bastion"
  })
}

resource "aws_instance" "app_a" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.app_instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.frontend.id]
  key_name                    = aws_key_pair.main.key_name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-a"
    Tier = "frontend"
  })
}

resource "aws_instance" "backend_b" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.backend_instance_type
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.backend.id]
  key_name               = aws_key_pair.main.key_name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-b"
    Tier = "backend"
  })
}

resource "aws_instance" "db_c" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.db_instance_type
  subnet_id              = aws_subnet.private_db.id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = aws_key_pair.main.key_name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-c"
    Tier = "database"
  })
}
