Scripts automatizados que crea y configura un sitio web estático en AWS S3 usando comandos de AWS CLI desde Windows.

Proceso paso a paso:

Validación de permisos ✅

Verifica que AWS CLI esté configurado
Comprueba que tienes permisos de S3
Muestra instrucciones si faltan permisos


Creación del bucket 📦

Genera nombre único con timestamp
Crea el bucket en la región especificada
Ejemplo: mi-sitio-estatico-20241227153045


Generación de contenido 📝

Crea archivo index.html con diseño moderno
HTML responsive con gradientes CSS
Guarda el archivo localmente


Subida de archivos ⬆️

Sube index.html al bucket S3
Configura el tipo de contenido correcto


Configuración de hosting 🌐

Habilita static website hosting
Define index.html como página principal
Configura página de error


Acceso público 🔓

Desbloquea restricciones de acceso público
Permite que el bucket sea visible en internet


Política de bucket 🔐

Crea archivo bucket-policy.json
Aplica política para lectura pública
Permite acceso GET a todos los objetos


Resultados 📊

Muestra la URL del sitio web
Lista archivos creados
Proporciona comandos útiles

