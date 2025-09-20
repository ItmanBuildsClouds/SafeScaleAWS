module "networking" {
  source = "./modules/networking"

  project_name      = var.project_name
  aws_region        = var.aws_region
  environment       = var.environment
  cidr_block        = var.cidr_block
  public_cidrs      = var.public_cidrs
  private_app_cidrs = var.private_app_cidrs
  private_db_cidrs  = var.private_db_cidrs
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name

}

module "compute" {
  source            = "./modules/compute"
  image_url         = module.ecr.ecr_url
  project_name      = var.project_name
  environment       = var.environment
  aws_region        = var.aws_region
  alb_sg            = module.networking.alb_sg
  app_sg            = module.networking.app_sg
  public_subnet_ids = module.networking.public_subnet_ids
  vpc_id            = module.networking.vpc_id
}

module "ecs" {
  source                 = "./modules/ecs"
  aws_region             = var.aws_region
  environment            = var.environment
  project_name           = var.project_name
  image_url              = module.ecr.ecr_url
  private_app_subnet_ids = module.networking.app_subnet_ids
  app_sg                 = module.networking.app_sg
  alb_target_group_arn   = module.compute.alb_target_group_arn
}
