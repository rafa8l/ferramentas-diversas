#!/bin/bash

# Opções
FILE_EXTENSION=""
MOVE_FILES=false
MAINTAIN_STRUCTURE=false
RENAME_HIDDEN=true

# Parse
while getopts "msr" opt; do
    case $opt in
        m) MOVE_FILES=true ;;
        s) MAINTAIN_STRUCTURE=true ;;
        r) RENAME_HIDDEN=true ;;
        e) FILE_EXTENSION="$OPTARG" ;;
        *) echo "Modo de usar: $0 [-m] [-s] [-r] [-e] <source_directory> <destination_directory>"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

SOURCE_DIR="$1"
DEST_DIR="$2"

# Validação
if [[ -z "$SOURCE_DIR" || -z "$DEST_DIR" ]]; then
    echo "Usage: $0 [-m] [-s] [-r] [-e] <source_directory> <destination_directory>"
    exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

mkdir -p "$DEST_DIR"

start_time=$(date +%s)
start_datetime=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="$DEST_DIR/process_log_$(date '+%Y%m%d_%H%M%S').log"
USER_NAME=$(whoami)

# Log e Terminal
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Processo iniciou em: $start_datetime by user: $USER_NAME"
echo "Pasta de origem: $SOURCE_DIR"

declare -A file_map

detect_and_copy_or_move() {
    local src_dir="$1"
    local dest_dir="$2"

    find "$src_dir" -type f | while IFS= read -r file; do
        if [[ -n "$FILE_EXTENSION" && "${file##*.}" != "$FILE_EXTENSION" ]]; then
            continue
        fi
        checksum=$(sha256sum "$file" | awk '{ print $1 }')
        
        if [[ -z "${file_map[$checksum]}" ]]; then
            file_map["$checksum"]=1
            
            if [[ "$MAINTAIN_STRUCTURE" == true ]]; then
                relative_path="${file#$src_dir/}"
                dest_path="$dest_dir/$relative_path"
                mkdir -p "$(dirname "$dest_path")"
            else
                base_name="$(basename -- "$file")"
                extension="${base_name##*.}"
                
                # Separa os arquivos em pastas por tipo
                if [[ "$base_name" == *.* ]]; then
                    dest_subdir="$dest_dir/$extension"
                else
                    dest_subdir="$dest_dir/unknown"
                fi
                mkdir -p "$dest_subdir"
                dest_path="$dest_subdir/$base_name"
                
                count=1
                while [[ -e "$dest_path" ]]; do
                    dest_path="$dest_subdir/${count}_$base_name"
                    ((count++))
                done
            fi
            
            if [[ "$MOVE_FILES" == true ]]; then
                mv "$file" "$dest_path"
                echo "Movido: $file -> $dest_path"
            else
                cp "$file" "$dest_path"
                echo "Copiado: $file -> $dest_path"
            fi
        else
            echo "Ignorado por duplicidade: $file"
        fi
    done
}

detect_and_copy_or_move "$SOURCE_DIR" "$DEST_DIR"

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
elapsed_hours=$((elapsed_time / 3600))
elapsed_minutes=$(((elapsed_time % 3600) / 60))
elapsed_seconds=$((elapsed_time % 60))

end_datetime=$(date '+%Y-%m-%d %H:%M:%S')
echo "Processo finalizado em: $end_datetime"
echo "Duração: ${elapsed_hours}h ${elapsed_minutes}m ${elapsed_seconds}s"

