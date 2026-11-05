# Devmy workspace

## Layout

`devmy new --name <workspace>` creates a pnpm + Nx monorepo in `./<workspace>` (kebab-case):

```
<workspace>/
  pnpm-workspace.yaml   # marks the workspace root: generate commands look for it
  package.json          # root scripts: dev, start, build, lint, lint:fix, test, test:headless, e2e, e2e:headless
  nx.json
  applications/<name>/  # devmy generate application …
  libraries/<name>/     # devmy generate library …
```

The scaffold also configures semantic-release, husky with commitlint (Conventional Commits) and dotenv-vault.

## What every command does

1. Downloads the brick from GitHub (needs network).
2. Runs the brick's `pre_gen` hook, writes the files, runs `post_gen`.
3. Runs `corepack pnpm i` in the workspace root.
4. Commits everything with a message like `chore(<name>): initial scaffold` or `chore: applied <addon>`.
5. Applies the addons chosen with `--addon`, each with its own install and commit.

`devmy new` also runs `git init --initial-branch=main` before its first commit.

Because of the commits, start from a clean working tree and do not stage unrelated changes before running a command.

## Names and ports

- `--name` is turned into kebab-case for the folder; the brick receives it as `workspaceName`, `applicationName` or `libraryName`.
- Applications get a default port (`--describe` shows it); override it with `--var port=<number>` to avoid clashes between apps of the same workspace.

## Running the result

```bash
cd <workspace>
pnpm run dev
```
