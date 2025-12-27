# Script en PowerShell para crear infraestructura S3 con sitio web estático
# Incluye validación de permisos

# Configuración
$BUCKET_NAME = "amzn-s3-staticwebsitemovil-empresa"
$REGION = "us-east-1"
$INDEX_FILE = "index.html"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Setup de S3 Static Website" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Función para verificar permisos
function Test-S3Permissions {
    Write-Host "Verificando permisos de AWS..." -ForegroundColor Yellow
    
    # Verificar identidad
    $identity = aws sts get-caller-identity 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: No se pudo verificar la identidad de AWS" -ForegroundColor Red
        Write-Host "Verifica que AWS CLI este configurado correctamente" -ForegroundColor Red
        return $false
    }
    
    # Intentar listar buckets (prueba de permisos básicos)
    Write-Host "Probando permisos de S3..." -ForegroundColor Yellow
    $testResult = aws s3 ls 2>&1
    
    if ($LASTEXITCODE -ne 0 -and $testResult -match "AccessDenied") {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Red
        Write-Host "ERROR: PERMISOS INSUFICIENTES" -ForegroundColor Red
        Write-Host "==========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Tu usuario de AWS no tiene los permisos necesarios." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "SOLUCION - Sigue estos pasos:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Inicia sesion en AWS Console: https://console.aws.amazon.com" -ForegroundColor White
        Write-Host "2. Ve a IAM > Users > [Tu Usuario]" -ForegroundColor White
        Write-Host "3. Click en 'Add permissions' > 'Attach policies directly'" -ForegroundColor White
        Write-Host "4. Busca y selecciona: AmazonS3FullAccess" -ForegroundColor Green
        Write-Host "5. Click en 'Add permissions'" -ForegroundColor White
        Write-Host ""
        Write-Host "O si no tienes acceso a la consola:" -ForegroundColor Yellow
        Write-Host "Contacta a tu administrador de AWS y solicita la politica 'AmazonS3FullAccess'" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Permisos especificos necesarios:" -ForegroundColor Cyan
        Write-Host "- s3:CreateBucket" -ForegroundColor Gray
        Write-Host "- s3:PutObject" -ForegroundColor Gray
        Write-Host "- s3:PutBucketWebsite" -ForegroundColor Gray
        Write-Host "- s3:PutBucketPolicy" -ForegroundColor Gray
        Write-Host "- s3:PutBucketPublicAccessBlock" -ForegroundColor Gray
        Write-Host ""
        
        # Mostrar información del usuario actual
        $identityJson = $identity | ConvertFrom-Json
        Write-Host "Usuario actual:" -ForegroundColor Cyan
        Write-Host "ARN: $($identityJson.Arn)" -ForegroundColor Gray
        Write-Host "Account: $($identityJson.Account)" -ForegroundColor Gray
        Write-Host ""
        
        return $false
    }
    
    Write-Host "Permisos verificados correctamente" -ForegroundColor Green
    Write-Host ""
    return $true
}

# Validar permisos antes de continuar
if (-not (Test-S3Permissions)) {
    Write-Host "Ejecuta este script nuevamente despues de agregar los permisos." -ForegroundColor Yellow
    exit 1
}

# 1. Crear el bucket S3
Write-Host "Creando bucket: $BUCKET_NAME" -ForegroundColor Yellow
aws s3 mb s3://$BUCKET_NAME --region $REGION

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al crear el bucket" -ForegroundColor Red
    exit 1
}
Write-Host "Bucket creado exitosamente" -ForegroundColor Green
Write-Host ""

# 2. Crear archivo index.html
Write-Host "Creando archivo index.html" -ForegroundColor Yellow
$indexContent = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sitio Estatico en S3</title>
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
    </style>
</head>
<body>
    <div class="container">
        <h1>Bienvenido!</h1>
        <p>Este es un sitio web estatico hospedado en <strong> S3</strong>.</p>
        <p>Creado y configurado automaticamente usando AWS CLI.</p>
        <div class="footer">
            <p>Powered by AWS S3 Static Website Hosting</p>
        </div>
    </div>
</body>
</html>
"@

Set-Content -Path $INDEX_FILE -Value $indexContent -Encoding UTF8
Write-Host "Archivo index.html creado" -ForegroundColor Green
Write-Host ""

# 3. Subir el archivo al bucket
Write-Host "Subiendo index.html al bucket" -ForegroundColor Yellow
aws s3 cp $INDEX_FILE s3://$BUCKET_NAME/

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al subir el archivo" -ForegroundColor Red
    Write-Host "Limpiando: eliminando bucket creado..." -ForegroundColor Yellow
    aws s3 rb s3://$BUCKET_NAME --force
    exit 1
}
Write-Host "Archivo subido exitosamente" -ForegroundColor Green
Write-Host ""

# 4. Configurar el bucket para hosting web
Write-Host "Configurando hosting de sitio web estatico" -ForegroundColor Yellow
aws s3 website s3://$BUCKET_NAME/ --index-document $INDEX_FILE --error-document $INDEX_FILE

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al configurar hosting web" -ForegroundColor Red
    Write-Host "Limpiando recursos..." -ForegroundColor Yellow
    aws s3 rb s3://$BUCKET_NAME --force
    exit 1
}
Write-Host "Hosting configurado" -ForegroundColor Green
Write-Host ""

# 5. Desbloquear acceso público
Write-Host "Desbloqueando acceso publico" -ForegroundColor Yellow
aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al desbloquear acceso publico" -ForegroundColor Red
    Write-Host "Limpiando recursos..." -ForegroundColor Yellow
    aws s3 rb s3://$BUCKET_NAME --force
    exit 1
}
Write-Host "Acceso publico desbloqueado" -ForegroundColor Green
Write-Host ""

# 6. Crear y aplicar política de bucket
Write-Host "Creando politica de bucket" -ForegroundColor Yellow

$policyJson = @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
"@

$policyJson | Out-File -FilePath "bucket-policy.json" -Encoding ASCII -NoNewline

Write-Host "Aplicando politica de bucket" -ForegroundColor Yellow
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al aplicar politica de bucket" -ForegroundColor Red
    Write-Host "Limpiando recursos..." -ForegroundColor Yellow
    aws s3 rb s3://$BUCKET_NAME --force
    exit 1
}
Write-Host "Politica aplicada exitosamente" -ForegroundColor Green
Write-Host ""

# 7. Mostrar información final
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "EXITO: Infraestructura creada!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Nombre del bucket: $BUCKET_NAME" -ForegroundColor White
Write-Host "Region: $REGION" -ForegroundColor White
Write-Host ""
Write-Host "URL del sitio web:" -ForegroundColor Yellow
Write-Host "http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivos creados localmente:" -ForegroundColor White
Write-Host "- $INDEX_FILE" -ForegroundColor Gray
Write-Host "- bucket-policy.json" -ForegroundColor Gray
Write-Host ""
Write-Host "Comandos utiles:" -ForegroundColor Yellow
Write-Host "Ver contenido: aws s3 ls s3://$BUCKET_NAME/" -ForegroundColor Gray
Write-Host "Subir archivos: aws s3 cp archivo.html s3://$BUCKET_NAME/" -ForegroundColor Gray
Write-Host "Eliminar bucket: aws s3 rb s3://$BUCKET_NAME --force" -ForegroundColor Gray
Write-Host ""
Write-Host "Abre la URL en tu navegador para ver el sitio!" -ForegroundColor Green
Write-Host ""