variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^(us|eu|ap)-[a-z]+-[0-9]$", var.aws_region))
    error_message = "La región debe tener formato como us-east-1, eu-west-3, ap-southeast-2."
  }
}

variable "s3_bucket_name" {
  description = "Nombre único del bucket S3"
  type        = string

  validation {
    condition     = length(var.s3_bucket_name) >= 3 && length(var.s3_bucket_name) <= 63
    error_message = "El nombre del bucket debe tener entre 3 y 63 caracteres."
  }
}

variable "create_bucket" {
  description = "Indica si Terraform debe crear el bucket o no"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Nombre del entorno para etiquetado"
  type        = string
  default     = "dev"
}

variable "s3_static_domain" {
  description = "Dominio del bucket S3 si no se crea con Terraform"
  type        = string
  default     = ""
}
