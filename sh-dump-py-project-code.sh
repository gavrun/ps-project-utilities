# Dump code from all project files of specified types to a single file
#
# Usage:
#   get_project_dump
#   get_project_dump ./project_dump.txt
#
get_project_dump() {
    local OUT_FILE="${1:-project_dump.txt}"
    local PROJECT_ROOT
    PROJECT_ROOT="$(pwd)"

    # File extensions to include:
    local INCLUDE_EXTENSIONS=(
        "*.py"
        "*.html"
        "*.css"
        "*.js"
        "*.json"
        "*.xml"
        "*.yml"
        "*.yaml"
        "*.toml"
        "*.ini"
        "*.cfg"
        "*.txt"
        "*.md"
    )

    # Directories to exclude
    local EXCLUDE_DIRS=(
        ".git"
        ".github"
        "__pycache__"
        ".pytest_cache"
        ".mypy_cache"
        ".ruff_cache"
        "venv"
        ".venv"
        "env"
        "node_modules"
        "dist"
        "build"
        "instance"
        "migrations"
    )

    # File name patterns to exclude
    local EXCLUDE_FILES=(
        ".env"
        ".flaskenv"
        "notes[0-9][0-9].txt"
        "project_dump.txt"
        "$(basename "$OUT_FILE")"
    )

    rm -f "$OUT_FILE"

    echo "Dumping code from: $PROJECT_ROOT"
    echo "Output file: $OUT_FILE"

    local FIND_ARGS=()

    # Add excluded directories
    for dir in "${EXCLUDE_DIRS[@]}"; do
        FIND_ARGS+=( -path "*/$dir/*" -prune -o )
    done

    # Add included file extensions
    FIND_ARGS+=( -type f \( )

    local first=true
    for ext in "${INCLUDE_EXTENSIONS[@]}"; do
        if [ "$first" = true ]; then
            FIND_ARGS+=( -name "$ext" )
            first=false
        else
            FIND_ARGS+=( -o -name "$ext" )
        fi
    done

    FIND_ARGS+=( \) -print )

    find "$PROJECT_ROOT" "${FIND_ARGS[@]}" | sort | while read -r file; do
        local filename
        filename="$(basename "$file")"

        # Skip sensitive, generated, or ignored files
        local skip=false

        for excluded in "${EXCLUDE_FILES[@]}"; do
            if [[ "$filename" == $excluded ]]; then
                skip=true
                break
            fi
        done

        if [ "$skip" = true ]; then
            continue
        fi

        local relative_path
        relative_path="${file#$PROJECT_ROOT/}"

        {
            echo
            echo "============================================================"
            echo "$relative_path"
            echo "============================================================"
            cat "$file"
            echo
        } >> "$OUT_FILE"
    done

    if [ -s "$OUT_FILE" ]; then
        echo "Dumped project files to: $OUT_FILE"
    else
        echo "No matching files found."
    fi
}
