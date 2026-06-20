#!/usr/bin/env bash
#
# Package one markdown post and its linked local assets, then optionally scp it.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_BASE="${TMPDIR:-/tmp}/move_md_pkg"

usage() {
  cat <<'EOF'
Usage:
  bash tools/move_md_src.sh -m <post.md> [-r <user@host:/path/>] [-o <archive.tar.gz>]

Options:
  -m, --markdown   Markdown file to package. Relative paths are resolved from repo root.
  -r, --remote     Optional SCP destination, e.g. user@host:/tmp/
  -o, --output     Optional output archive path. Defaults to ./<post-name>.tar.gz
  -h, --help       Show this help.

What it does:
  1. Reads the markdown file.
  2. Collects linked local assets under /assets/img and /assets/files.
  3. Copies the markdown and assets into a staging tree.
  4. Creates a .tar.gz archive.
  5. If --remote is provided, uploads the archive with scp.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

append_unique_line_array() {
  local value="$1"
  local item
  [[ -n "$value" ]] || return 0
  for item in "${LINE_ARRAY[@]-}"; do
    [[ "$item" == "$value" ]] && return 0
  done
  LINE_ARRAY+=("$value")
}

to_abs() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$path"
  fi
}

to_rel_from_root() {
  local abs="$1"
  case "$abs" in
    "$ROOT_DIR"/*) printf '%s\n' "${abs#"$ROOT_DIR"/}" ;;
    *) die "Path is outside repo root: $abs" ;;
  esac
}

copy_with_parents() {
  local rel="$1"
  local src="$ROOT_DIR/$rel"
  local dst="$STAGE_DIR/$rel"
  [[ -f "$src" ]] || die "Referenced file not found: $rel"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

collect_assets() {
  local md_abs="$1"
  local media_subpath=""
  local line ref clean

  RAW_REFS=()
  REL_REFS=()
  ASSET_RELS=()

  while IFS= read -r line; do
    if [[ "$line" =~ ^media_subpath:[[:space:]]*[\"\']?([^\"\']+)[\"\']?[[:space:]]*$ ]]; then
      media_subpath="${BASH_REMATCH[1]}"
    fi
  done <"$md_abs"

  while IFS= read -r line; do
    append_unique_line_array "$line"
  done < <(
    {
      rg -o --no-filename '/assets/(img|files)/[^)[:space:]"}]+' "$md_abs" || true
      rg -o --no-filename 'path:[[:space:]]*["'\'']?/assets/(img|files)/[^"'\''[:space:]]+' "$md_abs" \
        | sed -E 's/^path:[[:space:]]*["'\'']?//' || true
    } | sort -u
  )
  RAW_REFS=("${LINE_ARRAY[@]}")

  LINE_ARRAY=()
  while IFS= read -r line; do
    append_unique_line_array "$line"
  done < <(
    {
      rg -o --no-filename '!\[[^]]*\]\(([^):#][^)]*)\)' "$md_abs" \
        | sed -E 's/^!\[[^]]*\]\(([^)]*)\)$/\1/' || true
      rg -o --no-filename '\[[^]]*\]\(([^):#][^)]*)\)' "$md_abs" \
        | sed -E 's/^\[[^]]*\]\(([^)]*)\)$/\1/' || true
      rg -o --no-filename '^path:[[:space:]]*["'\'']?([^/"'\''][^"'\''[:space:]]*)' "$md_abs" \
        | sed -E 's/^path:[[:space:]]*["'\'']?//' || true
    } | sort -u
  )
  REL_REFS=("${LINE_ARRAY[@]}")

  for ref in "${RAW_REFS[@]}"; do
    clean="${ref%%\{}"
    clean="${clean%%\#*}"
    clean="${clean%%\?*}"
    clean="${clean#/}"
    [[ -n "$clean" ]] || continue
    ASSET_RELS+=("$clean")
  done

  if [[ -n "$media_subpath" ]]; then
    media_subpath="${media_subpath#/}"
    media_subpath="${media_subpath%/}"
    for ref in "${REL_REFS[@]}"; do
      clean="${ref%%\{}"
      clean="${clean%%\#*}"
      clean="${clean%%\?*}"
      [[ -n "$clean" ]] || continue
      [[ "$clean" == http://* || "$clean" == https://* || "$clean" == /* ]] && continue
      case "$clean" in
        *.png|*.jpg|*.jpeg|*.gif|*.svg|*.webp|*.avif|*.pdf|*.zip|*.txt|*.md|*.mp4|*.mp3)
          ASSET_RELS+=("${media_subpath}/${clean}")
          ;;
      esac
    done
  fi

  if [[ ${#ASSET_RELS[@]} -eq 0 ]]; then
    return 0
  fi

  LINE_ARRAY=()
  while IFS= read -r line; do
    append_unique_line_array "$line"
  done < <(printf '%s\n' "${ASSET_RELS[@]}" | sort -u)
  ASSET_RELS=("${LINE_ARRAY[@]}")
}

LINE_ARRAY=()
RAW_REFS=()
REL_REFS=()
ASSET_RELS=()
MARKDOWN_PATH=""
REMOTE_DEST=""
OUTPUT_PATH=""

while (($#)); do
  case "$1" in
    -m|--markdown)
      MARKDOWN_PATH="${2:-}"
      shift 2
      ;;
    -r|--remote)
      REMOTE_DEST="${2:-}"
      shift 2
      ;;
    -o|--output)
      OUTPUT_PATH="${2:-}"
      shift 2
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

[[ -n "$MARKDOWN_PATH" ]] || {
  usage
  die "--markdown is required"
}

require_cmd tar
require_cmd rg
if [[ -n "$REMOTE_DEST" ]]; then
  require_cmd scp
fi

MD_ABS="$(to_abs "$MARKDOWN_PATH")"
[[ -f "$MD_ABS" ]] || die "Markdown file not found: $MARKDOWN_PATH"

MD_REL="$(to_rel_from_root "$MD_ABS")"
POST_BASENAME="$(basename "${MD_REL%.*}")"
STAGE_DIR="$WORK_BASE/${POST_BASENAME}_stage"
ARCHIVE_DEFAULT="$ROOT_DIR/${POST_BASENAME}.tar.gz"
ARCHIVE_PATH="${OUTPUT_PATH:-$ARCHIVE_DEFAULT}"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

copy_with_parents "$MD_REL"
collect_assets "$MD_ABS"

if [[ ${#ASSET_RELS[@]} -gt 0 ]]; then
  for rel in "${ASSET_RELS[@]}"; do
    copy_with_parents "$rel"
  done
fi

MANIFEST="$STAGE_DIR/manifest.txt"
{
  printf 'markdown=%s\n' "$MD_REL"
  if [[ ${#ASSET_RELS[@]} -gt 0 ]]; then
    printf 'asset=%s\n' "${ASSET_RELS[@]}"
  fi
} >"$MANIFEST"

mkdir -p "$(dirname "$ARCHIVE_PATH")"
tar -C "$STAGE_DIR" -czf "$ARCHIVE_PATH" .

echo "Created archive: $ARCHIVE_PATH"
echo "Markdown: $MD_REL"
if [[ ${#ASSET_RELS[@]} -gt 0 ]]; then
  echo "Assets:"
  printf '  - %s\n' "${ASSET_RELS[@]}"
else
  echo "Assets: none"
fi

if [[ -n "$REMOTE_DEST" ]]; then
  scp "$ARCHIVE_PATH" "$REMOTE_DEST"
  echo "Uploaded to: $REMOTE_DEST"
fi
