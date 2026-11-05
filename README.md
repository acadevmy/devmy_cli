# Devmy CLI - The CLI tool for Devmy

<img src="/devmy.svg" alt="Devmy CLI logo" height="108px"/>

The Devmy CLI is a command-line interface tool that you use to initialize, develop, scaffold,
and maintain Devmy applications directly from a command shell.

Visit our [online doc](https://clidocs-devmy-pillars-projects.vercel.app)!

## Development Setup

### Requirements

- [Dart SDK](https://dart.dev/get-dart)
- Compatible Operating System: MacOS, Linux

### Installation Steps

#### Dart Activate

Install with dart tools:

```dart
dart pub global activate --source git https://github.com/acadevmy/devmy_cli
```


#### Install executable binaries

1. Navigate to the [latest release](https://github.com/acadevmy/devmy_cli/releases/latest) on GitHub.

2. Download the executable file compatible with your operating system:

    - For MacOS, download the `macos_latest.zip` file and extract the executable.

    - For Linux, download the `ubuntu_latest.zip` file and extract the executable.

3. Once the download is complete, move the executable file to a directory of your choice.

4. Set an environment variable `DEVMY_CLI_HOME` to the path where you placed the executable file. You can do this by
   adding the following line to your shell profile configuration file (e.g., `~/.bashrc`, `~/.bash_profile`, `~/.zshrc`,
   etc.):

   ```bash
   export DEVMY_CLI_HOME=/path/to/your/cli
   ```

   Replace `/path/to/your/cli` with the actual path where you placed the executable file.

5. Update your `PATH` environment variable to include the directory where the executable file is located. You can do
   this by adding the following line to your shell profile configuration file:

   ```bash
   export PATH="$DEVMY_CLI_HOME:$PATH"
   ```

6. Save the file and restart your terminal or run `source ~/.bashrc` (or the corresponding command for your shell
   configuration file) to apply the changes.

7. You can now use `devmy` command from any directory in your terminal.

## Setting Up a Project

Create a workspace:

```bash
devmy new
```

Run the application:

```bash
cd [WORKSPACE_NAME]
pnpm run dev
```

## AI agents

Teach your coding agent (Claude Code, Codex, Cursor, …) to use the CLI:

```bash
devmy skills install
```

It installs the `devmy` skill with [`npx skills`](https://skills.sh) (Node.js 22.20+), as a Claude Code plugin, or both. By hand:

```bash
npx skills add acadevmy/devmy_cli --skill devmy
```

```bash
claude plugin marketplace add acadevmy/devmy_cli && claude plugin install devmy@devmy
```

Agents run commands without a terminal, so every command can take its answers as flags (`--name`, `--addon`, `--var key=value`, `--target`) and `--describe` lists what a brick needs. See the [non-interactive mode](https://clidocs-devmy-pillars-projects.vercel.app/commands/non-interactive) docs.

## Development

```bash
make install           # dart pub get
make test              # dart test
make skill_reference   # regenerate skills/devmy/references/commands.md after changing the commands
```
