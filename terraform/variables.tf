# Input Variables
variable "location" {
  description = "The Azure region to deploy resources into."
  type        = string
  default     = "centralus"
}

variable "resource_name_suffix" {
  description = "A unique identifier to append to resource names."
  type        = string
  default     = "vmc" # Example default value, can be customized
}