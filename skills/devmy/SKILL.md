---
name: devmy
description: Scaffolds and extends Devmy pnpm/Nx monorepos with the devmy CLI. Creates a workspace (devmy new), generates applications (Angular, Next.js, NestJS, Directus, Shopware, Cypress, Firebase), libraries (TypeScript, Angular, CMS connector) and applies addons (Tailwind, Zustand, Next.js commerce and dynamic routes, GitLab CI, Vercel, Firebase Hosting). Use when the user asks to create a Devmy project or workspace, add an app or library to a Devmy monorepo, set up GitLab, Vercel or Firebase in it, or mentions the devmy CLI, bricks or pnpm-workspace.yaml in a Devmy project.
compatibility: Requires the devmy CLI on PATH, plus git and pnpm (via corepack). macOS or Linux.
metadata:
  cli-version: "1.33.1"
---

# devmy CLI

`devmy` generates code from Mason bricks downloaded from GitHub. Every command writes files, runs `pnpm i` and **creates a git commit** in the workspace, so run it on a clean working tree and tell the user what it committed.

## Before generating

1. Check the CLI: `devmy --version`. If it is missing, give the user the install command and stop:
   `dart pub global activate --source git https://github.com/acadevmy/devmy_cli`.
   If the version differs from `metadata.cli-version` above, trust `devmy <command> --help` over this skill.
2. Find the command in [references/commands.md](references/commands.md).
3. Print what its brick needs: `devmy <command> --describe`. It returns JSON with every variable (type, default, `required`) and the addon questions, and generates nothing.

## Running commands as an agent

Without a terminal the CLI never prompts: it runs non-interactively and every answer comes from flags. Pass `--no-interactive` anyway to make that explicit.

| Flag | Answers |
|---|---|
| `--name <name>` | the workspace, application or library name |
| `--addon <name>` | an addon question; repeat for several, omit to answer "none" |
| `--var key=value` | a brick variable listed by `--describe`; repeatable |
| `--target <package>` | where `generate addon` applies, by package.json name |

```bash
devmy new --name shop --no-interactive
cd shop
devmy generate application nextjs --name web --addon next/zustand --no-interactive
devmy g l ts --name utils --no-interactive
devmy g addon angular/tailwind --target backoffice --no-interactive
```

Exit codes: `0` success, `64` wrong or missing input (stderr names the exact flags to add, nothing was generated), `1` failure while generating. On `64`, add what stderr asks for and run again.

## Rules

- Run `generate` commands from inside the workspace (any folder under the one with `pnpm-workspace.yaml`); run `new` outside of it.
- Names become kebab-case folders: `applications/<name>`, `libraries/<name>`. See [references/workspace.md](references/workspace.md).
- Addons `vercel`, `gitlab`, `firebase` (application) and `firebase/hosting` need extra inputs, some of them secrets that only the user can provide. Read [references/addons.md](references/addons.md) before using them, and never put tokens in `--var` or in the conversation: ask the user to export them in their own shell.
- If a command must run interactively (the user prefers the prompts, or a secret is missing), give the user the exact command to run in their terminal (`! devmy …` in Claude Code) instead of guessing answers.
