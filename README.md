# gh-auto

A collection of Bash automation scripts for managing GitHub repositories following a persona-based directory structure.

## Installation Order

Follow these steps in order for initial setup:

### 1. Install GitHub CLI (First Time Only)

```bash
bash gh-gh-boot.sh
```

This will:
- Install GitHub CLI (`gh`) via Homebrew
- Authenticate you with GitHub (follow the prompts with the one-time code)
- **Required once** before any other tools can work

### 2. Install gh-auto

```bash
bash gh-installer.sh
```

This will:
- Move gh-auto to the standard location: `~/repos/git/adathelove/gh-auto`
- Create symlinks in `~/bin/` for all commands (removes `.sh` extension)
- Add gh-auto to your PATH via shell profile (`~/.zshrc` or `~/.bash_profile`)
- Make all tools available as commands (e.g., `gh-bootstrap`, `gh-list`)

### 3. Activate Your Environment

Restart your shell or run:
```bash
source ~/.zshrc  # or ~/.bash_profile for bash
```

### 4. Verify Installation

```bash
which gh-bootstrap  # Should show: /Users/Ada/bin/gh-bootstrap
gh-bootstrap --help
```

## Available Tools

Once installed, these commands are available system-wide:

### `gh-gh-boot`
Install and authenticate GitHub CLI via Homebrew.
```bash
gh-gh-boot
```

### `gh-installer`
Install gh-auto: move to standard location, create symlinks, configure environment.
```bash
gh-installer
```

### `gh-env`
Environment setup script (sourced automatically by shell profile after installation).
```bash
source gh-env  # Adds gh-auto to PATH and sets up completions
```

### `gh-ada-init`
Bootstrap gh-auto itself to the standard location (alternative to gh-installer).
```bash
gh-ada-init
```

### `gh-list`
Interactive GitHub repository browser using fzf.
```bash
gh-list
```
Browse your GitHub repositories and clone/pull them to the local directory structure.

### `gh-bootstrap`
Bootstrap any local directory into a GitHub repository.

```bash
gh-bootstrap <path> [--owner OWNER] [--name NAME] [--persona PERSONA] [--symlink] [--dry-run]
```

**What it does**:
- Ensures the target path is a git repo (creates one if needed)
- If there is no `origin`, prompts to create/push a GitHub repo via `gh repo create`
- Optional `--persona` + `--symlink` to place a symlink at `<persona>/repos/<name>`
- `--dry-run` to show what would happen without making changes

**Examples**:
- Bootstrap and push the current dir (uses gh auth user as owner):
  ```bash
  gh-bootstrap .
  ```
- Bootstrap an external path, symlink for persona Pyrikhos, but don't write (dry run):
  ```bash
  gh-bootstrap ~/repos/git/adathelove/gh-auto \
    --owner Adathelove \
    --persona Pyrikhos \
    --symlink \
    --dry-run
  ```
- Real run with symlink:
  ```bash
  gh-bootstrap ~/repos/git/adathelove/gh-auto \
    --owner Adathelove \
    --persona Pyrikhos \
    --symlink
  ```

**Flags**:
- `--owner`   GitHub owner (default: gh auth user or inferred from origin)
- `--name`    Repo name (default: basename of path)
- `--persona` Persona to receive the symlink
- `--symlink` Create the symlink when persona is provided
- `--dry-run` Show actions but make no changes

## Directory Structure

gh-auto follows a persona-based organization pattern:
```
~/repos/git/<owner>/<repo_name>/
```

Standard location for gh-auto itself:
```
~/repos/git/adathelove/gh-auto/
```

## Prerequisites

- macOS or Linux with Bash
- Homebrew (for gh-gh-boot)
- Internet connection (for GitHub operations)

## Notes

- If `origin` already exists, gh-bootstrap leaves it alone
- Prompts before creating a remote when one is missing
- In dry-run mode, no filesystem or remote changes occur
- All tools require GitHub CLI authentication (run `gh-gh-boot` first)
