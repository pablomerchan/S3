# Documentación: Sitio Web Estático en S3 con Terraform

Este proyecto despliega automáticamente un sitio web estático en Amazon S3 utilizando Terraform como herramienta de Infrastructure as Code (IaC).

## 🎯 Objetivo

Crear y configurar un bucket S3 con hosting público para servir contenido web estático de forma rápida y escalable.

## 📋 Prerequisitos

- **AWS CLI** configurado con credenciales válidas
- **Terraform** instalado (versión >= 1.0)
- **Permisos de AWS** necesarios:
  - `s3:CreateBucket`
  - `s3:PutObject`
  - `s3:PutBucketWebsite`
  - `s3:PutBucketPolicy`
  - `s3:PutBucketPublicAccessBlock`

## 🚀 Instalación y Uso

### 1. Clonar/Descargar el proyecto

```bash
mkdir s3-terraform
cd s3-terraform
# Guardar main.tf en esta carpeta
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Revisar el plan (opcional)

```bash
terraform plan
```

### 4. Desplegar la infraestructura

```bash
terraform apply
```

Confirmar con `yes` cuando se solicite.

### 5. Acceder al sitio web

Terraform mostrará la URL del sitio:
```
website_endpoint = "http://mi-sitio-estatico-xxx.s3-website-us-east-1.amazonaws.com"
```

## ⚙️ Configuración

### Variables personalizables

Crear un archivo `terraform.tfvars` para personalizar:

```hcl
bucket_name = "mi-nombre-de-bucket-unico"
aws_region  = "us-east-1"
```

### Estructura de archivos

```
s3-terraform/
├── main.tf              # Configuración principal de Terraform
├── terraform.tfvars     # Variables personalizadas (opcional)
├── terraform.tfstate    # Estado de Terraform (generado automáticamente)
└── .terraform/          # Directorio de providers (generado automáticamente)
```

## 🏗️ Recursos Creados

El script de Terraform crea los siguientes recursos:

1. **S3 Bucket** - Contenedor principal para archivos
2. **Website Configuration** - Configuración de hosting web
3. **Public Access Block** - Configuración de acceso público
4. **Bucket Policy** - Política para permitir lectura pública
5. **S3 Object** - Archivo index.html

## 📊 Outputs

Después del despliegue, obtendrás:

| Output | Descripción |
|--------|-------------|
| `bucket_name` | Nombre del bucket creado |
| `bucket_arn` | ARN del bucket |
| `website_endpoint` | URL completa del sitio web |
| `website_domain` | Dominio del sitio web |

## 🔧 Comandos Útiles

```bash
# Ver estado actual
terraform show

# Ver solo los outputs
terraform output

# Validar configuración
terraform validate

# Formatear código
terraform fmt

# Actualizar infraestructura
terraform apply

# Destruir todo
terraform destroy
```

## 📂 Agregar más archivos

Para subir archivos adicionales, agrega más recursos `aws_s3_object`:

```hcl
resource "aws_s3_object" "styles" {
  bucket       = aws_s3_bucket.website.id
  key          = "styles.css"
  source       = "styles.css"
  content_type = "text/css"
}
```

## 🗑️ Eliminación

Para destruir toda la infraestructura:

```bash
terraform destroy
```

Confirmar con `yes`. Esto eliminará:
- El bucket S3
- Todos los archivos dentro
- Las configuraciones asociadas

## 🔒 Seguridad

**⚠️ Advertencia**: Este bucket está configurado para ser **público**. No subas información sensible o privada.

### Recomendaciones:
- Usar solo para contenido público
- Implementar CloudFront para HTTPS
- Configurar políticas de acceso más restrictivas si es necesario
- Habilitar versionado para respaldos

## 🐛 Solución de Problemas

### Error: "Bucket name already exists"

**Causa**: El nombre del bucket ya está en uso globalmente.

**Solución**: Cambia el nombre en `terraform.tfvars`:
```hcl
bucket_name = "mi-nombre-unico-123"
```

### Error: "AccessDenied"

**Causa**: Tu usuario de AWS no tiene los permisos necesarios.

**Solución**: 
1. Ve a AWS Console → IAM → Users
2. Agrega la política `AmazonS3FullAccess`

### Error: "InvalidClientTokenId"

**Causa**: Credenciales de AWS incorrectas o expiradas.

**Solución**:
```bash
aws configure
# Ingresa nuevamente tus credenciales
```

## 📚 Recursos Adicionales

- [Documentación de Terraform](https://www.terraform.io/docs)
- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 📝 Notas

- El bucket generará un nombre único usando timestamp si no se especifica uno
- La región por defecto es `us-east-1`
- El sitio usa HTTP (no HTTPS). Para HTTPS, considera usar CloudFront
- Los cambios en `index.html` requieren ejecutar `terraform apply` nuevamente

## 👥 Autor

Proyecto creado para demostración de Infrastructure as Code con Terraform y AWS S3.

---

**Última actualización**: Diciembre 2024  
**Versión**: 1.0