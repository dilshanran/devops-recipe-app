variable "prefix" {
  description = "prefix for resources in AWS"
  default     = "raa"

}

variable "project" {
  description = "The name of the project"
  default     = "devops-recipe-app-api"

}

variable "contact" {
  description = "The contact person for the project"
  default     = "dilshan@gmail.com"

}

variable "db_username" {
  description = "Username for the recipe app api database"
  default     = "recipeapp"

}

variable "db_password" {
  description = "Password for the terraform database"

}

variable "ecr_proxy_image" {
  description = "Path to the ECR repo with the proxy image"
}

variable "ecr_app_image" {
  description = "Path to the ECR repo with the API image"
}

variable "django_secret_key" {
  description = "Secret Key for Django"
}
