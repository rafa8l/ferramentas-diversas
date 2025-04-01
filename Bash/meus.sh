#!/bin/bash

# Verifica o caminho da pasta
if [ -z "$1" ]; then
    echo "Uso: $0 <caminho_da_pasta>"
    exit 1
fi

# Usuário atual
USER=$(whoami)

# Altera o dono da pasta e de todos os arquivos dentro
sudo chown -R "$USER":"$USER" "$1"

# Altera permissões para garantir acesso total ao dono - opção
sudo chmod -R u+rw "$1"

echo "Permissões e propriedade ajustadas para '$USER' em '$1'"
