# Token Saving Techniques — Static Site

Single-page static HTML site deployed on Vercel at https://token-saving-techniques.vercel.app

## Content Guidelines

- **Only use official docs as references.** Do not rely on blog posts, community articles, or third-party guides. Official sources:
  - Claude Code: https://code.claude.com/docs
  - Cursor CLI: https://cursor.com/docs and https://cursor.com/changelog
  - Codex CLI: https://github.com/openai/codex (source of truth)
  - Gemini CLI: https://google-gemini.github.io/gemini-cli/docs and https://github.com/google-gemini/gemini-cli

- **Only document confirmed commands.** Before adding a command or config option, verify it exists by:
  1. Checking official docs/changelogs, or
  2. Checking source code in the tool's GitHub repo, or
  3. Running the command/tool locally (all four CLIs are installed — see Verification below)

- **Prefer slash commands** where available and where they make sense. Use slash command notation (`/plan`) over keyboard shortcuts or CLI flags when the slash command exists.

- **Do not mix IDE and CLI commands.** Cursor IDE shortcuts (⌘N, ⌘K, ⌘L) are different from Cursor CLI slash commands (/plan, /ask, /model). Be explicit about which context applies. The Cursor CLI binary is `agent`.

- **All statements must be validated against official vendor docs.** If a claim cannot be verified from official sources, either remove it or mark it as "(reported)" / "(unconfirmed)".

- **Run `./verify.sh` before deploying** to check that CLI tools are present and their --help output matches documented commands/flags.

## Installed Tools

| Tool | Binary | Version cmd |
|------|--------|-------------|
| Claude Code | `claude` | `claude --version` |
| Cursor CLI | `agent` | `agent --version` |
| Codex CLI | `codex` | `codex --version` |
| Gemini CLI | `gemini` | `gemini --version` |

## Verification

Run `./verify.sh` to check that documented CLI flags and subcommands exist in the locally installed tools. The script checks `--help` output for expected strings. Add new checks whenever a command or flag is added to the page.

## Tech Stack

- Pure static HTML + CSS (no build step, no framework)
- Deployed to Vercel as a static site
- Deploy: `vercel --prod --scope fintanmcevoy-4814s-projects`

## File Structure

- `index.html` — the entire site (single file)
- `verify.sh` — command/flag verification script
- `.vercel/` — Vercel project config (gitignored)
