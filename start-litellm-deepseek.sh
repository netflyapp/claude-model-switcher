#!/bin/zsh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/.env"
exec "$SCRIPT_DIR/.venv/bin/litellm" --config "$HOME/.litellm/config_deepseek.yaml" --port 4002
