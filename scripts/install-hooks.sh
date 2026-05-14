#!/usr/bin/env bash
# Install git hooks into .git/hooks
# Run this after cloning or to refresh hooks.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="${REPO_ROOT}/scripts/git-hooks"
GIT_HOOKS_DIR="${REPO_ROOT}/.git/hooks"

if [ ! -d "$HOOKS_DIR" ]; then
  echo "ERROR: $HOOKS_DIR not found" >&2
  exit 1
fi

for hook in "$HOOKS_DIR"/*; do
  hook_name=$(basename "$hook")
  target="${GIT_HOOKS_DIR}/${hook_name}"
  
  cp "$hook" "$target"
  chmod +x "$target"
  echo "Installed: $hook_name"
done

echo "All hooks installed."
