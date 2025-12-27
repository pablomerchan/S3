# Documentación: Sitio Web Estático en S3 con PowerShell

## 📖 Descripción

Este script automatiza la creación y configuración de un sitio web estático en Amazon S3 utilizando AWS CLI y PowerShell en Windows.

## 🎯 Objetivo

Desplegar automáticamente un bucket S3 configurado para hosting público de contenido web estático, con validación de permisos y manejo de errores.

## 📋 Prerequisitos

### Software necesario:
- **Windows PowerShell** 5.1 o superior (o PowerShell Core 7+)
- **AWS CLI** instalado y configurado
- **Cuenta de AWS** activa

### Permisos de AWS requeridos:
- `s3:ListAllMyBuckets` (para validación)
- `s3:CreateBucket`
- `s3:PutObject`
- `s3:PutBucketWebsite`
- `s3:PutBucketPolicy`
- `s3:PutBucketPublicAccessBlock`
- `s3:DeleteBucket` (para limpieza en caso de error)

## 🛠️ Instalación

### 1. Instalar AWS CLI

**Opción A - Instalador MSI (Recomendado):**
```powershell
# Descargar e instalar desde:
# https://awscli.amazonaws.com/AWSCLIV2.msi
```

**Opción B - Chocolatey:**
```powershell
choco install awscli
```

**Verificar instalación:**
```powershell
aws --version
```

### 2. Configurar AWS CLI

```powershell
aws configure
```

Ingresar:
- **AWS Access Key ID**: Tu clave de acceso
- **AWS Secret Access Key**: Tu clave secreta
- **Default region name**: `us-east-1` (o tu región preferida)
- **Default output format**: `json`

### 3. Verificar configuración

```powershell
aws sts get-caller-identity
```

## 🚀 Uso del Script

### 1. Descargar el script

Guardar el script como `setup-s3-website.ps1`

### 2. Configurar política de ejecución (solo primera vez)

```powershell
# Opción 1: Solo para la sesión actual (Recomendado)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Opción 2: Para el usuario actual (permanente)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3. Ejecutar el script

```powershell
cd C:\ruta\a\tu\carpeta
.\setup-s3-website.ps1
```

### 4. Acceder al sitio

El script mostrará la URL al finalizar:
```
URL del sitio web:
http://mi-sitio-estatico-xxxxx.s3-website-us-east-1.amazonaws.com
```

## ⚙️ Configuración Personalizada

### Modificar variables del script

Edita las primeras líneas de `setup-s3-website.ps1`:

```powershell
# Configuración
$BUCKET_NAME = "mi-nombre-personalizado"  # Nombre específico
$REGION = "us-west-2"                     # Cambiar región
$INDEX_FILE = "index.html"                # Archivo principal
```

### Usar nombre único automático (por defecto)

El script genera automáticamente un nombre único con timestamp:
```
mi-sitio-estatico-20241227153045
```

## 📊 Proceso del Script

### Flujo de ejecución:

1. **Validación de permisos** → Verifica credenciales y permisos de S3
2. **Creación de bucket** → Crea el bucket S3 con nombre único
3. **Generación de index.html** → Crea archivo HTML con diseño responsive
4. **Carga de archivo** → Sube index.html al bucket
5. **Configuración de hosting** → Habilita hosting web estático
6. **Acceso público** → Desbloquea configuraciones de acceso
7. **Política de bucket** → Aplica política para lectura pública
8. **Outputs** → Muestra URL y comandos útiles

### Recursos creados:

- 1 Bucket S3
- 1 Archivo index.html (local y en S3)
- 1 Archivo bucket-policy.json (local)
- Configuración de website hosting
- Política de acceso público

## 🎨 Personalizar index.html

### Opción 1: Editar directamente en el script

Modifica la sección `$indexContent`:

```powershell
$indexContent = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Mi Sitio Personalizado</title>
</head>
<body>
    <h1>Tu contenido aquí</h1>
</body>
</html>
"@
```

### Opción 2: Usar archivo existente

Si ya tienes un `index.html`:

```powershell
# En lugar de crear el contenido, usar:
Copy-Item -Path "tu-index.html" -Destination $INDEX_FILE
```

## 🔧 Comandos Útiles Post-Despliegue

### Ver contenido del bucket
```powershell
aws s3 ls s3://nombre-de-tu-bucket/
```

### Subir archivos adicionales
```powershell
# Un archivo
aws s3 cp styles.css s3://nombre-de-tu-bucket/

# Carpeta completa
aws s3 sync ./mi-sitio s3://nombre-de-tu-bucket/
```

### Descargar contenido del bucket
```powershell
aws s3 cp s3://nombre-de-tu-bucket/index.html ./backup/
```

### Actualizar index.html
```powershell
# Editar index.html local, luego:
aws s3 cp index.html s3://nombre-de-tu-bucket/ --acl public-read
```

### Eliminar el bucket y todo su contenido
```powershell
aws s3 rb s3://nombre-de-tu-bucket --force
```

### Ver configuración del bucket
```powershell
aws s3api get-bucket-website --bucket nombre-de-tu-bucket
```

## 🐛 Solución de Problemas

### ❌ Error: "Set-ExecutionPolicy: Access denied"

**Causa**: No tienes permisos de administrador.

**Solución**: Ejecuta PowerShell como administrador o usa:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

---

### ❌ Error: "InvalidClientTokenId"

**Causa**: Credenciales de AWS incorrectas o expiradas.

**Solución**:
```powershell
aws configure
# Volver a ingresar credenciales válidas
```

---

### ❌ Error: "AccessDenied"

**Causa**: Usuario sin permisos suficientes.

**Solución**:
1. Ir a AWS Console → IAM → Users → [Tu usuario]
2. Add permissions → Attach policies directly
3. Seleccionar: **AmazonS3FullAccess**
4. Guardar cambios

---

### ❌ Error: "BucketAlreadyExists"

**Causa**: El nombre del bucket ya existe (son únicos globalmente).

**Solución**: El script genera nombres únicos automáticamente. Si personalizaste el nombre, cambialo:
```powershell
$BUCKET_NAME = "otro-nombre-unico-123"
```

---

### ❌ Error: "MalformedPolicy"

**Causa**: Archivo JSON de política mal formateado.

**Solución**: Ya está corregido en la última versión del script. Vuelve a descargar el script actualizado.

---

### ❌ Script muestra: "ERROR: PERMISOS INSUFICIENTES"

**Causa**: La validación detectó falta de permisos.

**Solución**: Seguir las instrucciones que muestra el script:
1. Ir a AWS Console
2. Agregar política `AmazonS3FullAccess` a tu usuario
3. Ejecutar el script nuevamente

---

### ❌ El sitio web no carga (Error 403)

**Causa**: La política del bucket no se aplicó correctamente.

**Solución**:
```powershell
# Verificar que bucket-policy.json existe
Get-Content bucket-policy.json

# Reaplicar la política manualmente
aws s3api put-bucket-policy --bucket NOMBRE-BUCKET --policy file://bucket-policy.json
```

## 🔒 Consideraciones de Seguridad

### ⚠️ Advertencias Importantes:

- **Contenido público**: Todo el contenido del bucket será accesible públicamente
- **No subir datos sensibles**: Contraseñas, tokens, información privada
- **Sin HTTPS por defecto**: El sitio usa HTTP (no cifrado)

### 🛡️ Mejores Prácticas:

1. **Usar solo para contenido público**
2. **Implementar CloudFront** para:
   - Certificado SSL/TLS (HTTPS)
   - CDN global
   - Mejor rendimiento
3. **Habilitar versionado** para respaldos:
   ```powershell
   aws s3api put-bucket-versioning --bucket NOMBRE --versioning-configuration Status=Enabled
   ```
4. **Configurar logging** para auditoría:
   ```powershell
   aws s3api put-bucket-logging --bucket NOMBRE --bucket-logging-status file://logging.json
   ```
5. **Revisar políticas regularmente**

## 💰 Costos Estimados

### AWS S3 Pricing (us-east-1):
- **Almacenamiento**: ~$0.023 por GB/mes
- **Solicitudes GET**: $0.0004 por 1,000 solicitudes
- **Transferencia de datos**: Primeros 100 GB/mes gratis

### Ejemplo para sitio pequeño:
- 100 MB de contenido: ~$0.002/mes
- 10,000 visitas/mes: ~$0.04/mes
- **Total**: < $0.10/mes

**Nota**: Revisa siempre los precios actuales en: https://aws.amazon.com/s3/pricing/

## 📚 Estructura de Archivos Resultante

```
tu-carpeta/
├── setup-s3-website.ps1    # Script principal
├── index.html              # Página web (generada)
└── bucket-policy.json      # Política del bucket (generada)
```

## 🔄 Actualizar el Sitio

### Método 1: Editar y resubir

```powershell
# 1. Editar index.html localmente
notepad index.html

# 2. Subir cambios
aws s3 cp index.html s3://nombre-bucket/
```

### Método 2: Sincronizar carpeta completa

```powershell
# Mantener carpeta local sincronizada con S3
aws s3 sync ./mi-sitio s3://nombre-bucket/ --delete
```


### Información del sistema:
```powershell
# Verificar versiones instaladas
$PSVersionTable
aws --version
```

## 📝 Registro de Cambios

### v1.0 (Diciembre 2024)
- ✅ Versión inicial
- ✅ Validación automática de permisos
- ✅ Limpieza automática en caso de error
- ✅ Generación de nombres únicos
- ✅ Manejo robusto de errores
- ✅ Outputs informativos

---
