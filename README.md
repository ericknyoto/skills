# skills

Personal Claude Code skills, versioned here and installed with the [skills](https://skills.sh) CLI.

## Install

```bash
npx skills add ericknyoto/skills --skill coordinator -g -a claude-code -y
```

Update later with `npx skills update coordinator -g`. List what the repo offers with `npx skills add ericknyoto/skills -l`.

## Skills

| Skill | Invoke | Purpose |
|---|---|---|
| `coordinator` | `/coordinator [first task]` | Turns a Fable session into an orchestrator for coding, research/planning and investigation: it keeps thinking, synthesis and review for itself and delegates exploration, production and drafting to cheaper workers picked from `~/.claude/rules/pstack-models.md`. |

`coordinator` reads model and effort values from `~/.claude/rules/pstack-models.md`; that file is not part of this repo.

## Hooks

`hooks/worktree/` makes Claude Code worktrees (Agent `isolation: "worktree"`, `EnterWorktree`, `claude -w`) ready to run: vendor / node_modules / .env copied from the main checkout by reflink, installs only when the lockfile differs. Wiring and options are in `hooks/worktree/README.md`. Needed because Claude's own worktree creation copies tracked files only and does not run the repo's git hooks.
