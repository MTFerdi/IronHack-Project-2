resource "aws_key_pair" "main" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)

  tags = { Name = "${local.name_prefix}-key" }
}
