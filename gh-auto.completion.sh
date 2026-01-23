# bash completion for gh-auto helper scripts
# shellcheck shell=bash
# Be robust under shells with 'set -e'
_gh_auto_restore_e=
case $- in *e*) _gh_auto_restore_e=1; set +e;; esac

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
    --owner|--path|--bare-new)
      COMPREPLY=( $(compgen -W "" -- "$cur") )
      return 0
      ;;
  esac

  COMPREPLY=( $(compgen -W "$_gh_auto_commands --owner --bare-new" -- "$cur") )
  return 0
}

complete -F _gh_auto_complete gh-new-public.sh gh-new-private.sh gh-bootstrap.sh

# restore errexit if it was set
[[ -n $_gh_auto_restore_e ]] && set -e
unset _gh_auto_restore_e
