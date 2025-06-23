#!/usr/bin/env zsh
set -e

# Script para instalar y configurar Python en Ubuntu con pyenv
# Autor: Brayan Diaz C
# Fecha: 23 ene 2025 (actualizado 21 jun 2025)

echo "🐍 Iniciando el proceso de instalación y configuración de Python con pyenv..."

# Función compatible para leer entrada desde Bash o Zsh
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
echo "📦 [1/10] Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y

echo "🔧 Instalando dependencias necesarias para compilar Python..."
sudo apt install -y \
git curl wget make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev \
ca-certificates

# 2. Instalar pyenv
if [ -d "$HOME/.pyenv" ]; then
  echo "⚠️ pyenv ya está instalado. Saltando clonación..."
else
  echo "🔄 Clonando el repositorio de pyenv..."
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
fi

# 3. Agregar configuración a archivos de entorno
echo "🧩 [2/10] Agregando configuración de pyenv a archivos de entorno..."

for config_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.zprofile"; do
  if [ ! -f "$config_file" ]; then
    touch "$config_file"
  fi
  if ! grep -q 'pyenv init' "$config_file"; then
    {
      echo ''
      echo '# Configuración de pyenv'
      echo 'export PYENV_ROOT="$HOME/.pyenv"'
      echo 'export PATH="$PYENV_ROOT/bin:$PATH"'
      echo 'eval "$(pyenv init --path)"'
      echo 'eval "$(pyenv init -)"'
    } >> "$config_file"
    echo "✅ Configuración añadida en $config_file"
  else
    echo "ℹ️ $config_file ya contiene configuración de pyenv. Saltando."
  fi
done

# 4. Aplicar configuración temporal
echo "🔄 [3/10] Aplicando configuración temporal..."
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# 5. Mostrar versiones disponibles
echo "📜 [4/10] Estas son las versiones de Python disponibles:"
pyenv install --list

# 6. Solicitar versión o usar la última estable
python_latest=$(pyenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
read_prompt "👉 ¿Qué versión de Python deseas instalar? (ENTER para instalar la última versión estable: $python_latest): " python_version

if [[ -z "$python_version" ]]; then
  python_version=$python_latest
  echo "🔁 No se ingresó ninguna versión. Se instalará: $python_version"
else
  echo "📥 Se instalará Python $python_version según tu elección."
fi

# 7. Instalar y establecer versión global
echo "⬇️ [5/10] Instalando Python $python_version..."
pyenv install "$python_version"
pyenv global "$python_version"

# 8. Verificar instalación
echo "🔍 [6/10] Verificando instalación..."
python --version

# 9. Instalar pip y paquetes básicos
echo "📦 [7/10] Instalando pip y herramientas esenciales..."
curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
rm get-pip.py
pip install --upgrade pip setuptools wheel

# 10. Instrucciones futuras
echo "🛠️ [8/10] Para actualizar pyenv en el futuro:"
echo "cd ~/.pyenv && git pull"

echo
echo "🎉 Python $python_version ha sido instalado y configurado exitosamente con pyenv."