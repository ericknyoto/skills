# Worktree hooks

Make a git worktree ready to run fast: env + dependencies copied from the main checkout (reflink, never symlink), install only when the lockfile differs.

- `setup.sh <worktree> [main]` - idempotent readiness. Copies `.env*`, `.php-version`, `.nvmrc`, `.npmrc`, `.tool-versions`, then `vendor/` and `node_modules/` (if absent). Runs `composer install` / the frozen Node install (pnpm, yarn, bun, npm) only if the lockfile differs from main's. Node is skipped when main has no `node_modules` (set `WORKTREE_SETUP_NODE_INSTALL=1` to force). For pnpm it runs `pnpm install --frozen-lockfile --offline` after the copy (~1 s) to relink nested workspace `node_modules`. Logs to stderr and to `<gitdir>/worktree-setup/setup.log` (`git -C <worktree> rev-parse --absolute-git-dir`), which is the only place to read it when Claude created the worktree.
- `create.sh` - Claude Code `WorktreeCreate` hook. Creates `<main>/.claude/worktrees/<name>` on branch `worktree-<name>` from `origin/<default>` (5 s fetch), runs `setup.sh`, prints only the path.
- `remove.sh` - `WorktreeRemove` hook. `git worktree remove --force --force` (handles locked worktrees) + prune; the branch is kept.

## Wire into `~/.claude/settings.json`

Verified 2026-10-22 on Claude Code 2.1.308: Laravel (manobo-2008, 181 MB vendor) ready in ~5 s, Next.js pnpm workspace (manobo_frontend, 1 GB node_modules) in ~5 s, no installs when lockfiles match.

```json
"hooks": {
  "WorktreeCreate": [{"hooks": [{"type": "command", "command": "/home/ericknyoto/Work/ericknyoto-skills/hooks/worktree/create.sh", "timeout": 600}]}],
  "WorktreeRemove": [{"hooks": [{"type": "command", "command": "/home/ericknyoto/Work/ericknyoto-skills/hooks/worktree/remove.sh"}]}]
}
```

## Standalone

`hooks/worktree/setup.sh /path/to/worktree` after a manual `git worktree add`, or from a repo `.git/hooks/post-checkout`:

```sh
[ "$1" = 0000000000000000000000000000000000000000 ] && exec /home/ericknyoto/Work/ericknyoto-skills/hooks/worktree/setup.sh "$(git rev-parse --show-toplevel)"
```

## Options

- `CLAUDE_WORKTREE_BASE=<ref>` - base the new worktree on this ref (e.g. a feature branch) instead of `origin/<default>`.
- `CLAUDE_WORKTREE_RUN_GIT_HOOKS=1` - keep repo git hooks during creation (off by default so a repo `post-checkout` does not duplicate `setup.sh`).
