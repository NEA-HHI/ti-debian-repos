#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <path-to-debian-dir> <commit-id> --name \"Your Name\" --email your@email.com"
    exit 1
}

if [[ $# -lt 5 ]]; then usage; fi

DEBIAN_DIR=""
COMMIT=""
NAME=""
EMAIL=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)
            NAME="$2"
            shift 2
            ;;
        --email)
            EMAIL="$2"
            shift 2
            ;;
        *)
            if [[ -z "$DEBIAN_DIR" ]]; then
                DEBIAN_DIR="$1"
                shift
            elif [[ -z "$COMMIT" ]]; then
                COMMIT="$1"
                shift
            else
                echo "Unknown argument: $1"
                usage
            fi
            ;;
    esac
done

if [[ ! -f "$DEBIAN_DIR/changelog" ]]; then
    echo "Error: '$DEBIAN_DIR/changelog' not found"
    exit 1
fi

if [[ -z "$NAME" || -z "$EMAIL" ]]; then
    usage
fi

export DEBFULLNAME="$NAME"
export DEBEMAIL="$EMAIL"

DATE_STR=$(date +%Y%m%d)
VERSION="1.0+git${DATE_STR}.${COMMIT}-1"

# Call dch from within the specified directory
(
    cd "$DEBIAN_DIR"
    dch --check-dirname-level 0 -b -v "$VERSION" "Update to commit $COMMIT"
)

echo "Updated changelog at $DEBIAN_DIR/changelog with version: $VERSION"
