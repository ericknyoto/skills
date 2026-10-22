#!/usr/bin/env bash
# Claude Code WorktreeRemove hook. Removes a worktree under <repo>/.claude/worktrees/
# and prunes (double --force: Claude-locked worktrees too). Branch kept; missing path = success.
set -euo pipefail
exec 3>&1 1>&2

log() { printf 'worktree-remove: %s\n' "$*"; }
die() { printf 'worktree-remove: ERROR: %s\n' "$*"; exit 1; }

input=$(cat)
if command -v jq >/dev/null 2>&1; then
    path=$(printf '%s' "$input" | jq -r '.worktree_path // empty')
else
    path=$(printf '%s' "$input" | python3 -I -c 'import json,sys; v=json.load(sys.stdin).get("worktree_path"); print("" if v is None else v)')
fi
[ -n "$path" ] || die "no worktree_path in hook input"
case $path in /*) ;; *) die "worktree_path is not absolute: $path" ;; esac
case $path in */.claude/worktrees/?*) ;; *) die "refusing: $path is not inside a .claude/worktrees/ directory" ;; esac

if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    log "already gone: $path"
    owner=${path%%/.claude/worktrees/*}
    [ -d "$owner" ] && git -C "$owner" worktree prune 2>/dev/null || true
    exit 0
fi

path=$(readlink -f "$path")
common=$(git -C "$path" rev-parse --git-common-dir) || die "$path is not a git worktree"
case $common in /*) ;; *) common="$path/$common" ;; esac
main=$(dirname "$(cd "$common" && pwd -P)")
[ "$path" != "$main" ] || die "refusing to remove the main checkout: $path"
git -C "$main" worktree list --porcelain | grep -qxF "worktree $path" || die "$path is not a registered worktree of $main"

git -C "$main" worktree remove --force --force "$path" || die "git worktree remove failed for $path"
git -C "$main" worktree prune
log "removed $path (branch kept)"
