#!/bin/sh
#
# Script para compilar naabu estáticamente usando Docker
# y extraer el binario final.
#

# --- Configuración ---
IMAGE_NAME="naabu-builder"
CONTAINER_NAME="naabu-temp-container"
FINAL_BINARY_NAME="naabu-static"
# ---------------------

echo "==> 1. Construyendo la imagen de Docker... (Esto puede tardar varios minutos)"
# Usamos sudo en caso de que tu usuario no esté en el grupo 'docker'
sudo docker build -t $IMAGE_NAME .

# Revisa si la compilación falló
if [ $? -ne 0 ]; then
    echo "¡Error! La compilación de Docker falló."
    exit 1
fi

echo "==> 2. Creando un contenedor temporal..."
sudo docker create --name $CONTAINER_NAME $IMAGE_NAME

echo "==> 3. Extrayendo el binario 'naabu' del contenedor..."
# Copia el binario desde la ruta final en la etapa 'scratch'
sudo docker cp $CONTAINER_NAME:/usr/local/bin/naabu ./$FINAL_BINARY_NAME

# Revisa si la copia falló
if [ $? -ne 0 ]; then
    echo "¡Error! No se pudo copiar el binario desde el contenedor."
    echo "Limpiando el contenedor..."
    sudo docker rm $CONTAINER_NAME
    exit 1
fi

echo "==> 4. Limpiando el contenedor temporal..."
sudo docker rm $CONTAINER_NAME

echo ""
echo "¡Éxito!"
echo "Tu binario estático está listo: ./${FINAL_BINARY_NAME}"
file ./$FINAL_BINARY_NAME
