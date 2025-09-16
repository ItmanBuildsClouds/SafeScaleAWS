module "networking" {
    source = "./modules/networking"

    project_name = var.project_name
    aws_region = var.aws_region
    environment = var.environment
    cidr_block = var.cidr_block
    public_cidrs = var.public_cidrs
    private_app_cidrs = var.private_app_cidrs
    private_db_cidrs = var.private_db_cidrs
}