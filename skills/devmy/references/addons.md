# Addons

An addon changes an existing project of the workspace. Apply it in one of two ways:

- while generating, by answering the command's question: `devmy g a nextjs --name web --addon vercel`
- later, on a project chosen by package.json name: `devmy g addon vercel --target web`

`devmy g addon <name> --target <x> --no-interactive` without a valid target fails with the list of valid package names.

Run `devmy g addon <name> --describe` for the variables of each addon brick. The four addons below also read inputs that `--describe` cannot list, because their hooks ask for them.

## Addons that need extra inputs

### `vercel`

Links the application to two Vercel projects (staging, production) and adds the deploy steps to GitLab CI.

- Secrets, from the environment only: `VERCEL_TOKEN_STAGING`, `VERCEL_TOKEN_PRODUCTION` (https://vercel.com/account/tokens, one account per environment).
- Standalone it also needs `--var applicationName=<name>`; when applied from `generate application` it inherits the name.
- Needs an active dotenv-vault session in the workspace.

### `firebase` (application)

`devmy g a firebase --name <name>` configures four Firebase environments.

- Secrets, from the environment only: `FIREBASE_TOKEN_DEVELOPMENT`, `FIREBASE_TOKEN_STAGING`, `FIREBASE_TOKEN_CI`, `FIREBASE_TOKEN_PRODUCTION` (`pnpm dlx firebase-tools login:ci`).
- Optional project ids: `--var firebaseProjectDevelopment=<id>` (and `Staging`, `Ci`, `Production`). An environment left out is configured later in `.firebaserc`.
- Needs an active dotenv-vault session in the workspace.

### `gitlab`

Configures GitLab CI and semantic-release for GitLab.

- Reads the repository from `git remote get-url origin`. When there is no valid GitLab remote, pass `--var repositoryBaseUrl=<https or ssh url>`.
- Ends by printing four manual steps in GitLab settings (default branch, protected branches, merge requests, CI variables). Show them to the user: an agent cannot do them.
- Needs an active dotenv-vault session to print the CI keys.

### `firebase/hosting`

Adds Angular applications to Firebase Hosting (`firebase.json`, `.firebaserc`). Apply it to the Firebase application.

- `--var hostingApplications=<name,name>` or `--var hostingApplications=all`: required without a terminal.
- `--var overwriteHostings=true` replaces hosting targets that already exist; the default `false` keeps them.

## Secrets

Never pass tokens with `--var` and never ask the user to paste them in the conversation. Ask them to export the variables in their shell, or to run the command themselves in their terminal.
