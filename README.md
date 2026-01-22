# gh-auto

Lightweight helper to bootstrap any local directory into a GitHub repo and (optionally) link it into a persona’s `repos/` tree.

## Script

`gh-bootstrap.sh` does the following:
- Ensures the target path is a git repo (creates one if needed).
- If there is no `origin`, prompts to create/push a GitHub repo via `gh repo create`.
- Optional `--persona` + `--symlink` to place a symlink at `<persona>/repos/<name>`.
- `--dry-run` to show what would happen without making changes.

## Usage

From anywhere (requires `gh` auth):

```bash
./gh-bootstrap.sh <path> [--owner OWNER] [--name NAME] [--persona PERSONA] [--symlink] [--dry-run]
```

Examples:
- Bootstrap and push the current dir (uses gh auth user as owner):
  ```bash
  ./gh-bootstrap.sh .
  ```
- Bootstrap an external path, symlink for persona Pyrikhos, but don’t write (dry run):
  ```bash
  ./gh-bootstrap.sh ~/repos/git/adathelove/gh-auto \
    --owner Adathelove \
    --persona Pyrikhos \
    --symlink \
    --dry-run
  ```
- Real run with symlink:
  ```bash
  ./gh-bootstrap.sh ~/repos/git/adathelove/gh-auto \
    --owner Adathelove \
    --persona Pyrikhos \
    --symlink
  ```

## Flags
- `--owner`   GitHub owner (default: gh auth user or inferred from origin)
- `--name`    Repo name (default: basename of path)
- `--persona` Persona to receive the symlink
- `--symlink` Create the symlink when persona is provided
- `--dry-run` Show actions but make no changes

## Prereqs
- GitHub CLI (`gh`) logged in: `gh auth status`.
- Write access to the target path.

## Notes
- If `origin` already exists, the script leaves it alone.
- Prompts before creating a remote when one is missing.
- In dry-run mode, no filesystem or remote changes occur.
