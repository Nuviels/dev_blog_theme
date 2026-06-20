#!/usr/bin/env bash
#
# Unpack a packaged markdown post archive into this repo and clean up.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_BASE="${TMPDIR:-/tmp}/move_md_unpack"

usage() {
  cat <<'EOF'
Usage:
  bash tools/move_md_dec.sh -a <archive.tar.gz> [-k]

Options:
  -a, --archive    Archive created by move_md_src.sh
  -k, --keep       Keep extracted temp directory and source archive
  -h, --help       Show this help.

What it does:
  1. Extracts the archive.
  2. Copies _posts/... and assets/... into the current repo.
  3. Removes temp files and, by default, the archive itself.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

to_abs() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$PWD" "$path"
  fi
}

copy_tree() {
  local rel_root="$1"
  local src="$EXTRACT_DIR/$rel_root"
  local dst="$ROOT_DIR/$rel_root"

  [[ -d "$src" ]] || return 0

  while IFS= read -r file; do
    local rel="${file#"$src"/}"
    mkdir -p "$dst/$(dirname "$rel")"
    cp "$file" "$dst/$rel"
  done < <(find "$src" -type f | sort)
}

ARCHIVE_PATH=""
KEEP_FILES=false

while (($#)); do
  case "$1" in
    -a|--archive)
      ARCHIVE_PATH="${2:-}"
      shift 2
      ;;
    -k|--keep)
      KEEP_FILES=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      die "Unknown option: $1"
      ;;
  esac
done

[[ -n "$ARCHIVE_PATH" ]] || {
  usage
  die "--archive is required"
}

ARCHIVE_ABS="$(to_abs "$ARCHIVE_PATH")"
[[ -f "$ARCHIVE_ABS" ]] || die "Archive not found: $ARCHIVE_PATH"

ARCHIVE_NAME="$(basename "$ARCHIVE_ABS" .tar.gz)"
EXTRACT_DIR="$WORK_BASE/${ARCHIVE_NAME}_extract"

rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"

tar -C "$EXTRACT_DIR" -xzf "$ARCHIVE_ABS"

copy_tree "_posts"
copy_tree "assets"

echo "Imported into: $ROOT_DIR"
if [[ -f "$EXTRACT_DIR/manifest.txt" ]]; then
  echo "Manifest:"
  sed -n '1,120p' "$EXTRACT_DIR/manifest.txt"
fi

if ! $KEEP_FILES; then
  rm -rf "$EXTRACT_DIR"
  rm -f "$ARCHIVE_ABS"
  echo "Cleaned extracted files and archive"
else
  echo "Kept extracted files: $EXTRACT_DIR"
fi
