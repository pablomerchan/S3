# main.tf - Infraestructura S3 para sitio web estático con Terraform

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuración del provider de AWS
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nombre del bucket S3 (debe ser único globalmente)"
  type        = string
  default     = "amzn-s3-staticwebsitemovil-empresa"  # Si está vacío, se genera automáticamente
}

# Generar nombre único si no se proporciona
locals {
  bucket_name = var.bucket_name != "" ? var.bucket_name : "mi-sitio-estatico-${formatdate("YYYYMMDDhhmmss", timestamp())}"
}

# 1. Crear el bucket S3
resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name

  tags = {
    Name        = "Static Website Bucket"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 2. Configurar el bucket para hosting de sitio web estático
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# 3. Desbloquear el acceso público del bucket
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Crear la política del bucket para acceso público
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# 5. Subir el archivo index.html
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content_type = "text/html"
  
  content = <<-EOT
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Sitio Estatico en S3</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        h1 {
            text-align: center;
            font-size: 2.5em;
            margin-bottom: 20px;
        }
        p {
            font-size: 1.2em;
            line-height: 1.6;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            opacity: 0.8;
        }
        .info {
            background: rgba(255, 255, 255, 0.05);
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>¡Bienvenido!</h1>
        <p>Este es un sitio web estatico hospedado en <strong>Amazon S3</strong>.</p>
        <p>Fue creado y configurado automaticamente usando <strong>Terraform</strong>.</p>
        <div class="info">
            <p><strong>Infraestructura como Código (IaC)</strong></p>
            <p>Este sitio fue desplegado usando Terraform, permitiendo una gestión declarativa y reproducible de la infraestructura.</p>
        </div>
        <div class="footer">
            <p>Powered by AWS S3 + Terraform</p>
        </div>
    </div>
</body>
</html>
EOT

  depends_on = [aws_s3_bucket_policy.website]
}

# Outputs - Mostrar información importante
output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.website.id
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.website.arn
}

output "website_endpoint" {
  description = "URL del sitio web estatico"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "website_domain" {
  description = "Dominio del sitio web"
  value       = aws_s3_bucket_website_configuration.website.website_domain
}