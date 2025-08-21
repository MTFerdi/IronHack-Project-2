locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
  }
  az = "${var.aws_region}${var.az_suffix}"
}
