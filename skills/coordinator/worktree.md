# Worktrees for code producers

Code-mode reference for `SKILL.md`. Read before sending the first code producer.

`isolation: "worktree"` creates a checkout at `<repo>/.claude/worktrees/<name>` from `origin/<default branch>`, containing
tracked files only: no `vendor/`, `node_modules/` or `.env`. Consequences for the brief:

- Name the base branch explicitly. A producer that must work on top of another branch runs `git fetch` and `git checkout`
  itself, and you commit or push first if the producer needs your changes.
- On this machine the global `WorktreeCreate` hook (`~/Work/ericknyoto-skills/hooks/worktree/`) already copies `vendor/`,
  `node_modules/`, `.env`, `.php-version` and `.nvmrc`, and installs dependencies only when the lockfile differs. Its log is at
  `$(git rev-parse --absolute-git-dir)/worktree-setup/setup.log` inside the worktree.
- The producer still verifies readiness before running anything: `vendor/` or `node_modules/` present, `.env` present, runtime
  version correct (`.php-version` or `.nvmrc`). If the hook did not run (another machine), the producer runs
  `setup.sh <worktree>` from that hook folder, or `cp -a` from the main checkout and installs dependencies only if the lockfile
  differs.
- `vendor/` is always copied, never symlinked: a symlink makes tests silently run the main checkout's code.
- Test evidence from a worktree is valid only when its stack traces point at that worktree's path.
- Parallel producers share no files. Two producers that need the same file means one producer, or the second one waits.
- Stacked PRs are avoided; when unavoidable, the merge order goes into the PR title and into your report.
