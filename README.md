# gh-auto

Lightweight helper to bootstrap any local directory into a GitHub repo and (optionally) link it into a persona’s `repos/` tree.

## Script

`gh-bootstrap.sh` does the following:
- Ensures the target path is a git repo (creates one if needed).
- If there is no `origin`, prompts to create/push a GitHub repo via `gh repo create`.
- Optionally symlinks the target into a persona folder (`<persona>/repos/<name>`).

## Usage

From the mythos repo (or anywhere):

```bash
./gh-bootstrap.sh <path> [--owner OWNER] [--name NAME] [--persona PERSONA] [--symlink]
```

Examples:
- Bootstrap and push the current dir using your gh auth user as owner:
  ```bash
  ./gh-bootstrap.sh .
  ```
- Bootstrap an external path and symlink it for persona Pyrikhos:
  ```bash
  ./gh-bootstrap.sh ~/repos/git/adathelove/gh-auto \
    --owner Adathelove \
    --persona Pyrikhos \
    --symlink
  ```

Flags:
- `--owner`   GitHub owner (default: gh auth user or inferred from origin).
- `--name`    Repo name (default: basename of path).
- `--persona` Persona to receive the symlink.
- `--symlink` Create the symlink when persona is provided.

## Prereqs
- GitHub CLI (`gh`) logged in: `gh auth status`.
- Write access to the target path.

## Notes
- If `origin` already exists, the script leaves it alone (no new repo created).
- Symlink is created only when `--persona` and `--symlink` are both given.
- Prompts before creating a remote if one is missing.
