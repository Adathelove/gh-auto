# gh-auto

Lightweight Bash helpers for bootstrapping GitHub repos. Chaos owns this toolchain; it lives at
`~/repos/git/mythos/Chaos/repos/gh-auto`.

## Quick start

1) Install GitHub CLI and log in (one time):
```bash
bash gh-gh-boot.sh
```

2) Add gh-auto to PATH (one time):
```bash
echo 'source ~/repos/git/mythos/Chaos/repos/gh-auto/gh-env.sh' >> ~/.zshrc   # or ~/.bash_profile
source ~/.zshrc
```

3) Verify:
```bash
which gh-bootstrap.sh
gh-bootstrap.sh --help
```

## Core commands

- `gh-new-public.sh [PATH] [--owner OWNER] [--bare-new NAME] [--dry-run]`
- `gh-new-private.sh [PATH] [--owner OWNER] [--bare-new NAME] [--dry-run]`
  - Repo name = basename of PATH (or NAME when using `--bare-new`)
  - Owner defaults to your active `gh auth` account (Adathelove)
  - `--bare-new NAME` creates a subdir, seeds README + BSD-3, commits, then creates/pushes the repo
  - `--dry-run` prints actions only

Underlying engine:
- `gh-bootstrap.sh [PATH] [--owner OWNER] [--bare-new NAME] [--dry-run]`
  - Visibility is controlled by env var `GHB_MODE` (`public` default, `private` honored by the wrappers).
- `gh-list.sh [--owner OWNER] [--no-fzf]` browse/select your GitHub repos with fzf
- `gh-repo-owner.sh` detect GitHub owner from various sources
- `gh-env` adds gh-auto to PATH and loads completions

## Common flows

Bootstrap the current directory (public):
```bash
gh-bootstrap.sh
```

Bootstrap the current directory as private:
```bash
GHB_MODE=private gh-bootstrap.sh
# or use the wrapper:
gh-new-private.sh
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
