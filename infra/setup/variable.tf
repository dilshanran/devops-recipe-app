variable "tf_state_bucket" {
  description = "The name of the S3 bucket to store Terraform state"
  default     = "devops-app-recipe-state"

}

variable "tf_state_lock_table" {
  description = "The name of the DynamoDB table to use for state locking"
  default     = "devops-recipe-app-api-tflock"

}

variable "project" {
  description = "The name of the project"
  default     = "devops-recipe-app-api"

}

variable "contact" {
  description = "The contact person for the project"
  default     = "dilshan@gmail.com"

}
