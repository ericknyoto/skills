#!/usr/bin/env bash
# Make an existing git worktree ready to run: copy env/runtime files and
# dependency directories from the main checkout, and install dependencies only
# when the lockfile differs. Idempotent. All output goes to stderr.
#
# Usage: setup.sh <worktree_path> [main_checkout_path]
# Env:   WORKTREE_SETUP_NODE_INSTALL=1  also run the frozen Node install when
#        the main checkout has no node_modules (default: skip Node then).
set -euo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX 2>/dev/null || true

exec 1>&2

log() { printf 'worktree-setup: %s\n' "$*"; }
die() { printf 'worktree-setup: ERROR: %s\n' "$*" >&2; exit 2; }

now() { printf '%s' "${EPOCHREALTIME:-$(date +%s.%N)}"; }
elapsed_since() { awk -v a="$1" -v b="$(now)" 'BEGIN { printf "%.1f", b - a }'; }

[ $# -ge 1 ] || die "usage: setup.sh <worktree_path> [main_checkout_path]"
[ -d "$1" ] || die "not a directory: $1"
wt=$(cd "$1" && pwd -P)

if [ $# -ge 2 ] && [ -n "$2" ]; then
    main=$(cd "$2" && pwd -P)
else
    common=$(git -C "$wt" rev-parse --git-common-dir) || die "not a git worktree: $wt"
    case $common in /*) ;; *) common="$wt/$common" ;; esac
    main=$(cd "$(dirname "$(cd "$common" && pwd -P)")" && pwd -P)
fi

[ "$wt" = "$main" ] && exit 0

gitdir=$(git -C "$wt" rev-parse --absolute-git-dir) || die "cannot find git dir of $wt"
stampdir="$gitdir/worktree-setup"
mkdir -p "$stampdir"
exec > >(tee -a "$stampdir/setup.log" >&2) 2>&1
printf '\n=== %s ===\n' "$(date -Is)"

start=$(now)
copied=()
installed=()
skipped=()
rc=0

lock_sha() { if [ -f "$1" ]; then sha256sum "$1" | cut -d' ' -f1; else echo none; fi; }

# True when the path exists in any form (incl. dangling symlink).
present() { [ -e "$1" ] || [ -L "$1" ]; }

# Copy a directory tree atomically (reflink when supported, plain cp -a else).
# Symlinks inside are copied as symlinks, never followed.
copy_tree() {
    local src=$1 dst=$2 tmp="$2.wt-setup.$$"
    rm -rf -- "$tmp"
    if ! cp -a --reflink=auto -- "$src" "$tmp" 2>/dev/null; then
        rm -rf -- "$tmp"
        cp -a -- "$src" "$tmp" || { rm -rf -- "$tmp"; return 1; }
    fi
    mv -- "$tmp" "$dst"
    if [ -n "$(find "$dst" -type l -lname "$main/*" -print -quit 2>/dev/null)" ]; then
        log "WARNING: $(basename "$dst") contains absolute symlinks into $main"
    fi
}

# 1. env / runtime files
for f in .env .env.local .env.testing .php-version .nvmrc .npmrc .tool-versions; do
    if [ -f "$main/$f" ] && ! present "$wt/$f"; then
        cp -p -- "$main/$f" "$wt/$f"
        copied+=("$f")
        log "$f copied"
    fi
done

# 2. PHP
setup_php() {
    [ -f "$wt/composer.json" ] || return 0
    local stamp="$stampdir/composer.sha" t0
    if [ -d "$main/vendor" ] && [ ! -L "$main/vendor" ] && ! present "$wt/vendor"; then
        t0=$(now)
        if copy_tree "$main/vendor" "$wt/vendor"; then
            lock_sha "$main/composer.lock" > "$stamp"
            copied+=("vendor")
            log "vendor copied in $(elapsed_since "$t0")s"
        else
            log "vendor copy FAILED"
            rc=1
        fi
    fi

    local need=0 reason=""
    if [ ! -d "$wt/vendor" ]; then
        need=1; reason="no vendor directory"
    elif [ -f "$stamp" ]; then
        [ "$(cat "$stamp")" = "$(lock_sha "$wt/composer.lock")" ] || { need=1; reason="composer.lock changed since last install"; }
    else
        cmp -s "$main/composer.lock" "$wt/composer.lock" || { need=1; reason="composer.lock differs from main"; }
    fi

    if [ "$need" = 0 ]; then
        lock_sha "$wt/composer.lock" > "$stamp"
        log "composer: vendor up to date, no install"
        return 0
    fi

    command -v composer >/dev/null 2>&1 || { log "composer not found; install skipped ($reason)"; rc=1; return 0; }
    if [ -z "${COMPOSER_AUTH:-}" ] && command -v gh >/dev/null 2>&1; then
        local token
        token=$(gh auth token 2>/dev/null || true)
        if [ -n "$token" ]; then
            COMPOSER_AUTH="{\"github-oauth\":{\"github.com\":\"$token\"}}"
            export COMPOSER_AUTH
        fi
    fi
    log "composer install ($reason)"
    t0=$(now)
    if (cd "$wt" && composer install --no-interaction --no-progress --prefer-dist); then
        lock_sha "$wt/composer.lock" > "$stamp"
        installed+=("composer")
        log "composer install done in $(elapsed_since "$t0")s"
    else
        log "composer install FAILED; run it manually in $wt"
        rc=1
    fi
}

# 3. Node
setup_node() {
    [ -f "$wt/package.json" ] || return 0
    local pm="" lockname="" pair
    for pair in pnpm-lock.yaml:pnpm yarn.lock:yarn bun.lockb:bun bun.lock:bun package-lock.json:npm; do
        if [ -f "$wt/${pair%%:*}" ]; then lockname=${pair%%:*}; pm=${pair##*:}; break; fi
    done

    local stamp="$stampdir/node.sha" t0 forced=0 nm_copied=0
    local main_has_nm=0
    [ -d "$main/node_modules" ] && [ ! -L "$main/node_modules" ] && main_has_nm=1

    if ! present "$wt/node_modules"; then
        if [ "$main_has_nm" = 1 ]; then
            t0=$(now)
            if copy_tree "$main/node_modules" "$wt/node_modules"; then
                lock_sha "$main/$lockname" > "$stamp"
                copied+=("node_modules")
                nm_copied=1
                log "node_modules copied in $(elapsed_since "$t0")s"
            else
                log "node_modules copy FAILED"
                rc=1
            fi
        elif [ -z "$pm" ]; then
            skipped+=("node")
            log "node skipped: package.json but no node_modules in main and no lockfile"
            return 0
        elif [ "${WORKTREE_SETUP_NODE_INSTALL:-0}" = 1 ]; then
            forced=1
        else
            skipped+=("node")
            log "node skipped: main has no node_modules (set WORKTREE_SETUP_NODE_INSTALL=1 to install)"
            return 0
        fi
    fi

    [ -n "$pm" ] || { log "node: no lockfile, nothing to install"; return 0; }

    local need=0 reason=""
    if [ "$forced" = 1 ] || [ ! -d "$wt/node_modules" ]; then
        need=1; reason="no node_modules"
    elif [ -f "$stamp" ]; then
        [ "$(cat "$stamp")" = "$(lock_sha "$wt/$lockname")" ] || { need=1; reason="$lockname changed since last install"; }
    else
        cmp -s "$main/$lockname" "$wt/$lockname" || { need=1; reason="$lockname differs from main"; }
    fi

    if [ "$need" = 0 ]; then
        lock_sha "$wt/$lockname" > "$stamp"
        if [ "$pm" = pnpm ] && [ "$nm_copied" = 1 ]; then
            t0=$(now)
            log "pnpm: relinking workspace packages offline (nested node_modules are not copied)"
            (cd "$wt" && pnpm install --frozen-lockfile --offline) || { log "pnpm relink FAILED; run it manually in $wt"; rc=1; }
            log "pnpm relink done in $(elapsed_since "$t0")s"
        else
            log "$pm: node_modules up to date, no install"
        fi
        return 0
    fi

    command -v "$pm" >/dev/null 2>&1 || { log "$pm not found; install skipped ($reason)"; rc=1; return 0; }
    local cmd
    case $pm in
        pnpm) cmd=(pnpm install --frozen-lockfile --prefer-offline) ;;
        npm)  cmd=(npm ci) ;;
        yarn) cmd=(yarn install --frozen-lockfile) ;;
        bun)  cmd=(bun install --frozen-lockfile) ;;
    esac
    log "${cmd[*]} ($reason)"
    t0=$(now)
    if (cd "$wt" && "${cmd[@]}"); then
        lock_sha "$wt/$lockname" > "$stamp"
        installed+=("$pm")
        log "$pm install done in $(elapsed_since "$t0")s"
    else
        log "$pm install FAILED; run it manually in $wt"
        rc=1
    fi
}

setup_php
setup_node

join() { local IFS=,; echo "${*:-none}"; }
log "summary: copied=[$(join "${copied[@]+"${copied[@]}"}")] installed=[$(join "${installed[@]+"${installed[@]}"}")] skipped=[$(join "${skipped[@]+"${skipped[@]}"}")] in $(elapsed_since "$start")s"
exit "$rc"
