variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Nombre único del bucket S3"
  type        = string
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

# Variables para EC2
variable "ec2_ami" {
  description = "AMI para la instancia EC2"
  type        = string
  default     = "ami-0a313d6098716f372" # Ejemplo para us-east-1 (Ubuntu 22.04)
}

variable "ec2_instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "Nombre del Key Pair para EC2"
  type        = string
}
