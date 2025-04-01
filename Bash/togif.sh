#!/bin/bash

# Confere se o ffmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo "Erro: ffmpeg não está instalado!"
    echo "Para instalar:"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "  - Ubuntu/Debian: sudo apt install ffmpeg"
        echo "  - Fedora: sudo dnf install ffmpeg"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  - macOS: brew install ffmpeg"
    fi
    exit 1
fi

if [ -z "$1" ]; then
    echo "Uso: $0 <arquivo_de_entrada>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.*}.gif"

# Opção de loop no arquivo final
read -p "Com loop infinito? (s/n): " loopsnvar

if [[ "$loopsnvar" == "s" ]]; then
    LOOP_FLAG=0
else
    LOOP_FLAG=-1
fi

# Converte o vídeo para GIF
ffmpeg -i "$INPUT_FILE" -vf "fps=12,scale=512:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop "$LOOP_FLAG" "$OUTPUT_FILE"

echo "Conversão concluída: $OUTPUT_FILE"
