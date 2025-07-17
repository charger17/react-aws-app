variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^us|^eu|^ap", var.aws_region))
    error_message = "Solo se permiten regiones que empiecen con 'us', 'eu', o 'ap'."
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
