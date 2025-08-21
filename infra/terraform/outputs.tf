output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_app_subnet_id" {
  value = aws_subnet.private_app.id
}

output "private_db_subnet_id" {
  value = aws_subnet.private_db.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "app_a_public_ip" {
  value = aws_instance.app_a.public_ip
}

output "backend_b_private_ip" {
  value = aws_instance.backend_b.private_ip
}

output "db_c_private_ip" {
  value = aws_instance.db_c.private_ip
}
