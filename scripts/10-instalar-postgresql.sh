#!/usr/bin/env zsh
set -e

# Script para instalar y configurar PostgreSQL en Ubuntu/WSL
# Autor: Brayan Diaz C
# Fecha: 25 jun 2025

echo "🐘 Iniciando el proceso de instalación y configuración de PostgreSQL..."

# Función para lectura de entrada compatible con Zsh y Bash
read_prompt() {
  local __msg="$1"
  local __varname="$2"
  if [[ -n "$ZSH_VERSION" ]]; then
    echo -n "$__msg"
    read "$__varname"
  else
    read -p "$__msg" "$__varname"
  fi
}

# 1. Actualizar el sistema
echo "📦 [1/9] Actualizando sistema..."
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y

# 2. Mostrar ayuda visual y solicitar versión
default_pg_version="17"
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Se instalará PostgreSQL en tu sistema"
echo "🔢 Versión por defecto sugerida: $default_pg_version"
echo "👉 Si no estás seguro, presiona ENTER para continuar con esta versión."
echo "💡 También puedes escribir una versión diferente (ej: 16, 15, etc)."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read_prompt "¿Qué versión de PostgreSQL deseas instalar?: " pg_version
pg_version=${pg_version:-$default_pg_version}
echo "🔁 Se instalará PostgreSQL $pg_version"
echo

# 3. Añadir repositorio oficial
echo "➕ [2/9] Añadiendo el repositorio oficial de PostgreSQL..."
sudo apt install -y wget lsb-release gnupg postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

# 4. Instalar PostgreSQL
echo "⬇️ [3/9] Instalando PostgreSQL $pg_version..."
sudo apt update
sudo apt install -y "postgresql-$pg_version"

# 5. Verificar instalación
echo "🔍 [4/9] Verificando instalación..."
psql --version

# 6. Activar y habilitar servicio
echo "🔧 [5/9] Habilitando y arrancando el servicio de PostgreSQL..."
sudo systemctl enable postgresql
sudo systemctl start postgresql

# 7. Crear usuario y establecer contraseña
echo "👤 [6/9] Configurando usuario local para PostgreSQL..."
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname = '$USER'" | grep -q 1; then
  echo "⚠️ El usuario '$USER' ya existe en PostgreSQL."
else
  sudo -u postgres createuser --superuser "$USER"
fi

echo "🔐 Establece una contraseña para el usuario '$USER' en PostgreSQL:"
sudo -u postgres psql -c "\password $USER"

# 8. Probar conexión
echo "🔗 [7/9] Probando conexión local a PostgreSQL..."
psql -d postgres || echo "⚠️ La conexión puede fallar si la autenticación no está correctamente configurada."

# 9. Recomendaciones adicionales
echo "📘 [8/9] Recomendaciones:"
echo "- Si deseas compilar extensiones o conectarte desde otros lenguajes:"
echo "  sudo apt install libpq-dev"
echo "- Para verificar estado: systemctl status postgresql"
echo "- Para desinstalar una versión específica: sudo apt remove postgresql-<versión>"

# 10. Mensaje final
echo
echo "🎉 [9/9] PostgreSQL $pg_version ha sido instalado y configurado exitosamente."