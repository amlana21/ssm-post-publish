terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }

}

provider "aws" {
  region  = "us-east-1"
  profile = ""
}


module "security" {
  source = "./security"
}

module "networking_module" {
  source = "./networking"
}

module "compute" {
  source                = "./compute"
  task_role_arn         = module.security.task_execution_role_arn
  subnet_ids            = module.networking_module.subnet_ids
  task_sg_id            = module.networking_module.task_sg_id
  target_grp_arn        = module.networking_module.tg_arn
  api_target_grp_arn    = module.networking_module.api_tg_arn
  vpc_id                = module.networking_module.vpc_id
  lb_sg_id              = module.networking_module.lb_sg_id
  instance_profile_name = module.security.instance_profile_name
}
