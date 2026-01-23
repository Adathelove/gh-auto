# bash completion for gh-auto helper scripts
# shellcheck shell=bash

_gh_auto_commands="
gh-new-public.sh
gh-new-private.sh
gh-bootstrap.sh
gh-ada-init.sh
gh-gh-boot.sh
gh-installer.sh
gh-list.sh
gh-repo-owner.sh
gh-env.sh
"

_gh_auto_complete() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "$prev" in
    --owner|--name|--path|--persona|--bare-new)
      COMPREPLY=( $(compgen -W "" -- "$cur") )
      return 0
      ;;
  esac

  COMPREPLY=( $(compgen -W "$_gh_auto_commands --owner --name --bare-new" -- "$cur") )
  return 0
}

complete -F _gh_auto_complete gh-new-public.sh gh-new-private.sh gh-bootstrap.sh
