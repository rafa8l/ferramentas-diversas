#!/bin/bash

# Valores e Opções
NUM_FILES=100
BATCH_BASE=""

# Opções
while getopts "n:b:" opt; do
  case $opt in
    n) NUM_FILES="$OPTARG" ;;
    b) BATCH_BASE="$OPTARG" ;;
    *) echo "Modo de uso: $0 -n <number_of_files> [-b batch_base] <source_directory>"
       exit 1 ;;
  esac
done

shift $((OPTIND - 1))
SRC_DIR="$1"

# Validação
if [[ -z "$SRC_DIR" || ! -d "$SRC_DIR" ]]; then
  echo "Error: Source directory is invalid or not provided."
  exit 1
fi

# Padrão para o caso de não for dado um novo nome para as pastas a serem criadas.
if [[ -z "$BATCH_BASE" ]]; then
  BATCH_BASE=$(basename "$SRC_DIR")
fi

# Log
LOG_FILE="$SRC_DIR/split_folder.log"

# Log não vai pra lista de arquivos a serem movidos
touch "$LOG_FILE"

# Log e terminal
log() {
  echo "$1" | tee -a "$LOG_FILE"
}

echo "----------------------------" > "$LOG_FILE"
log "Processo iniciou em: $(date '+%Y-%m-%d %H:%M:%S')"
log "Pasta de origem: $SRC_DIR"
log "Número de arquivos por sub-pasta: $NUM_FILES"
log "Nome base para as sub-pastas: $BATCH_BASE"
log "Usuário: $(whoami)"
log "----------------------------"

START_TIME=$(date +%s)

# Organiza os arquivos em Array (ignora pastas e o log)
FILES=()
for file in "$SRC_DIR"/*; do
  [[ -f "$file" && "$file" != "$LOG_FILE" ]] && FILES+=("$file")
done

# Processamento
BATCH=1
INDEX=0

while [[ $INDEX -lt ${#FILES[@]} ]]; do
  DEST_DIR="$SRC_DIR/${BATCH_BASE}_${BATCH}"
  mkdir -p "$DEST_DIR"

  log "Folder: $(basename "$DEST_DIR")/"

  for ((i = 0; i < NUM_FILES && INDEX < ${#FILES[@]}; i++, INDEX++)); do
    FILE_NAME="${FILES[$INDEX]}"
    mv "$FILE_NAME" "$DEST_DIR/"
    log "Moved: $(basename "$FILE_NAME")"
  done

  log ""
  ((BATCH++))
done

# Log
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
log "----------------------------"
log "Processo terminou em: $(date '+%Y-%m-%d %H:%M:%S')"
log "Duração: $((ELAPSED / 3600))h $(((ELAPSED % 3600) / 60))m"
log "----------------------------"

echo "Log salvo: $LOG_FILE"
