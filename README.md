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
| `coordinator` | `/coordinator [tugas pertama]` | Turns a Fable session into an orchestrator: it keeps thinking, synthesis and review for itself and delegates exploration, implementation and drafting to cheaper workers picked from `~/.claude/rules/pstack-models.md`. |

`coordinator` reads model and effort values from `~/.claude/rules/pstack-models.md`; that file is not part of this repo.
