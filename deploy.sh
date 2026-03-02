#!/bin/bash

# --- CONFIGURACIÓN ---
#export SITE_URL="https://eva.intiinside.com"
export DB_NAME="moodle"
export DB_USER="moodle"
export DB_PASS="moodle"  

# Generar archivo .env
echo "Generando entorno..."
cat <<EOF > .env
SITE_URL=$SITE_URL
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS
EOF

echo "--- 1. Construyendo Imagen Propia (Esto tomará unos minutos) ---"
docker compose build

echo "--- 2. Levantando Infraestructura ---"
docker compose up -d

echo "--- 3. Verificando Código Moodle ---"
# Verificamos si ya existe código
if [ -z "$(ls -A ./html)" ]; then
    echo "Descargando Moodle 4.3 (Latest Stable)..."
    # Descargamos DENTRO del contenedor para evitar problemas de red del host
    docker compose exec -T app sh -c "curl -L https://download.moodle.org/download.php/direct/stable403/moodle-latest-403.tgz | tar xz --strip-components=1"
    
    echo "Asignando permisos correctos..."
    docker compose exec -T app chown -R www-data:www-data /var/www/html
    docker compose exec -T app chown -R www-data:www-data /var/www/moodledata
    docker compose exec -T app chmod -R 755 /var/www/html
else
    echo "El código ya existe. Omitiendo descarga."
fi

echo -e "\n--- ¡DESPLIEGUE FINALIZADO! ---"
echo "Accede a: $SITE_URL"
echo "Tus archivos están en: /opt/moodleip/html"