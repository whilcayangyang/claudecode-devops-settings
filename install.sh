#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

link() {
    local src="${SCRIPT_DIR}/$1"
    local dst="${CLAUDE_DIR}/$2"

    if [[ ! -e "${src}" && ! -d "${src}" ]]; then
        echo "  SKIP  $2 (source not found: ${src})"
        return
    fi

    if [[ -L "${dst}" && "$(readlink "${dst}")" == "${src}" ]]; then
        echo "  OK    $2 (already linked)"
        return
    fi

    ln -sf "${src}" "${dst}"
    echo "  LINKED $2 -> ${src}"
}

mkdir -p "${CLAUDE_DIR}"

link "settings.json" "settings.json"
link "CLAUDE.md"     "CLAUDE.md"
link "hooks"         "hooks"

echo "Done."
