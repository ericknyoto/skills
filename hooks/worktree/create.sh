#!/usr/bin/env bash
# Claude Code WorktreeCreate hook. Replaces Claude's own git creation:
# creates <main>/.claude/worktrees/<name> on branch worktree-<name>, readies it
# with setup.sh, and prints ONLY the absolute worktree path on stdout.
# Env: CLAUDE_WORKTREE_BASE=<ref> overrides the base ref (default origin/<default branch>).
#      CLAUDE_WORKTREE_RUN_GIT_HOOKS=1 keeps the repo's git hooks during `git worktree add`.
set -euo pipefail
exec 3>&1 1>&2

log() { printf 'worktree-create: %s\n' "$*"; }
die() { printf 'worktree-create: ERROR: %s\n' "$*"; exit 1; }

input=$(cat)
json_get() {
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$input" | jq -r --arg k "$1" '.[$k] // empty'
    else
        printf '%s' "$input" | python3 -I -c 'import json,sys; v=json.load(sys.stdin).get(sys.argv[1]); print("" if v is None else v)' "$1"
    fi
}
name=$(json_get name)
cwd=$(json_get cwd)
[ -n "$cwd" ] || cwd=$PWD

[ -n "$name" ] || die "no name in hook input"
case $name in
    *[!A-Za-z0-9._-]* | .* | -*) die "unsafe worktree name: $name" ;;
esac

root=$(git -C "$cwd" rev-parse --show-toplevel) || die "not a git repository: $cwd"
common=$(git -C "$cwd" rev-parse --git-common-dir)
case $common in /*) ;; *) common="$cwd/$common" ;; esac
common=$(cd "$common" && pwd -P)
main=$(dirname "$common")

default=$(git -C "$main" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)
default=${default#origin/}
if [ -z "$default" ]; then
    for cand in main master; do
        if git -C "$main" show-ref --verify --quiet "refs/remotes/origin/$cand" \
            || git -C "$main" show-ref --verify --quiet "refs/heads/$cand"; then
            default=$cand
            break
        fi
    done
fi
[ -n "$default" ] || log "no default branch found; basing on current HEAD"

if [ -n "$default" ] && git -C "$main" remote get-url origin >/dev/null 2>&1; then
    timeout 5 git -C "$main" fetch --quiet origin "$default" || log "fetch of origin/$default failed or timed out; continuing"
fi

if [ -n "${CLAUDE_WORKTREE_BASE:-}" ]; then
    base=$CLAUDE_WORKTREE_BASE
    git -C "$main" rev-parse --verify --quiet "$base^{commit}" >/dev/null || die "CLAUDE_WORKTREE_BASE is not a valid ref: $base"
elif [ -n "$default" ] && git -C "$main" show-ref --verify --quiet "refs/remotes/origin/$default"; then
    base="origin/$default"
elif [ -n "$default" ] && git -C "$main" show-ref --verify --quiet "refs/heads/$default"; then
    base=$default
else
    base=$(git -C "$root" rev-parse HEAD)
fi

path="$main/.claude/worktrees/$name"
branch="worktree-$name"
mkdir -p "$main/.claude/worktrees"

exclude="$common/info/exclude"
mkdir -p "$(dirname "$exclude")"
touch "$exclude"
grep -qE '^(\*\*/)?\.claude/worktrees/$' "$exclude" || printf '.claude/worktrees/\n' >> "$exclude"

hookopt=(-c core.hooksPath=/dev/null)
[ "${CLAUDE_WORKTREE_RUN_GIT_HOOKS:-0}" = 1 ] && hookopt=()

if git -C "$main" worktree list --porcelain | grep -qxF "worktree $path"; then
    log "worktree already exists, reusing: $path"
elif [ -e "$path" ]; then
    die "$path exists but is not a registered worktree"
elif git -C "$main" show-ref --verify --quiet "refs/heads/$branch"; then
    log "branch $branch exists, reusing it"
    git -C "$main" "${hookopt[@]}" worktree add "$path" "$branch" || die "git worktree add failed"
else
    log "creating $branch from $base"
    git -C "$main" "${hookopt[@]}" worktree add --no-track -b "$branch" "$path" "$base" || die "git worktree add failed"
fi

here=$(dirname "$(readlink -f "$0")")
"$here/setup.sh" "$path" "$main" || log "setup.sh reported problems (exit $?); the worktree exists, finish readiness manually"

echo "$path" >&3
