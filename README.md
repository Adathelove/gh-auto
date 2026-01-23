# gh-auto

Lightweight Bash helpers for bootstrapping GitHub repos. Chaos owns this toolchain; it lives at
`~/repos/git/mythos/Chaos/repos/gh-auto` (with an optional symlink at `~/repos/git/adathelove/gh-auto`).

## Quick start

1) Install GitHub CLI and log in (one time):
```bash
bash gh-gh-boot.sh
```

2) Add gh-auto to PATH (one time):
```bash
echo 'source ~/repos/git/mythos/Chaos/repos/gh-auto/gh-env' >> ~/.zshrc   # or ~/.bash_profile
source ~/.zshrc
```

3) Verify:
```bash
which gh-bootstrap.sh
gh-bootstrap.sh --help
```

## Core commands

**TODO - Missing files:**
- `gh-new-public.sh [PATH] [--owner OWNER] [--bare-new NAME] [--dry-run]` ⚠️ NOT YET IMPLEMENTED
- `gh-new-private.sh [PATH] [--owner OWNER] [--bare-new NAME] [--dry-run]` ⚠️ NOT YET IMPLEMENTED
  - Repo name = basename of PATH (or NAME when using `--bare-new`)
  - Owner defaults to your active `gh auth` account (Adathelove)
  - `--bare-new NAME` creates a subdir, seeds README + BSD-3, commits, then creates/pushes the repo
  - `--dry-run` prints actions only
  - **Note**: `gh-bootstrap.sh` has visibility hardcoded as `--public`; GHB_MODE environment variable not yet implemented

**Available now:**
- `gh-bootstrap.sh [PATH] [--owner OWNER] [--bare-new NAME] [--dry-run]` (currently hardcoded to public repos only)
- `gh-list.sh [--owner OWNER] [--no-fzf]` browse/select your GitHub repos with fzf
- `gh-repo-owner.sh` detect GitHub owner from various sources
- `gh-env` adds gh-auto to PATH and loads completions

## Common flows

Bootstrap the current directory (public):
```bash
gh-bootstrap.sh
```

Create a fresh repo in a new subdir (public):
```bash
gh-bootstrap.sh --bare-new my-new-repo
```

Bootstrap an existing dir:
```bash
gh-bootstrap.sh /path/to/dir
```

Dry run to see what would happen:
```bash
gh-bootstrap.sh --dry-run
```

## Prereqs
- macOS or Linux with Bash
- `gh` installed and authenticated (`gh auth status`)
- Network access to GitHub

## Notes
- Remote is created non-interactively; fails fast if it already exists.
- Initial commit is auto-created if none exists (README will be made if missing).
- Repo name is always the target basename; `--name` is intentionally not supported.
