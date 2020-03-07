# fish shell-like abbreviation management for zsh.
# https://github.com/olets/zsh-abbr
# v3.0.2
# Copyright (c) 2019-2020 Henry Bley-Vroman


# CONFIGURATION
# -------------

# Whether to add default bindings (expand on SPACE, expand and accept on ENTER,
# add CTRL for normal SPACE/ENTER; in incremental search mode expand on CTRL+SPACE)
ZSH_ABBR_DEFAULT_BINDINGS="${ZSH_ABBR_DEFAULT_BINDINGS=true}"

# File abbreviations are stored in
ZSH_ABBR_USER_PATH="${ZSH_ABBR_USER_PATH="${HOME}/.config/zsh/abbreviations"}"


# FUNCTIONS
# ---------

_zsh_abbr() {
  {
    local action_set number_opts opt opt_add opt_clear_session opt_dry_run \
          opt_erase opt_expand opt_export_aliases opt_import_git_aliases \
          opt_import_aliases opt_import_fish opt_list opt_list_commands \
          opt_print_version opt_rename opt_scope_session opt_scope_user \
          opt_type_global opt_type_regular type_set release_date scope_set \
          should_exit text_bold text_reset util_usage version
    action_set=false
    number_opts=0
    opt_add=false
    opt_clear_session=false
    opt_dry_run=false
    opt_erase=false
    opt_expand=false
    opt_export_aliases=false
    opt_type_global=false
    opt_import_aliases=false
    opt_import_fish=false
    opt_import_git_aliases=false
    opt_list=false
    opt_list_commands=false
    opt_type_regular=false
    opt_rename=false
    opt_scope_session=false
    opt_scope_user=false
    opt_print_version=false
    type_set=false
    release_date="March 7 2020"
    scope_set=false
    should_exit=false
    text_bold="\\033[1m"
    text_reset="\\033[0m"
    util_usage="
       ${text_bold}abbr${text_reset}: fish shell-like abbreviations for zsh

   ${text_bold}Synopsis${text_reset}
       ${text_bold}abbr${text_reset} --add|-a [SCOPE] ABBREVIATION EXPANSION
       ${text_bold}abbr${text_reset} --clear-session|-c [SCOPE] ABBREVIATION
       ${text_bold}abbr${text_reset} --erase|-e [SCOPE] ABBREVIATION
       ${text_bold}abbr${text_reset} --expand|-x ABBREVIATION
       ${text_bold}abbr${text_reset} --export-aliases|-o [SCOPE] [DESTINATION]
       ${text_bold}abbr${text_reset} --import-git-aliases [SCOPE]
       ${text_bold}abbr${text_reset} --import-aliases [SCOPE]
       ${text_bold}abbr${text_reset} --list-abbreviations|-l
       ${text_bold}abbr${text_reset} --list-commands|-L|-s
       ${text_bold}abbr${text_reset} --list-definitions
       ${text_bold}abbr${text_reset} --rename|-R [SCOPE] OLD_ABBREVIATION NEW

       ${text_bold}abbr${text_reset} --help|-h
       ${text_bold}abbr${text_reset} --version|-v

   ${text_bold}Description${text_reset}
       ${text_bold}abbr${text_reset} manages abbreviations - user-defined words
       that are replaced with longer phrases after they are entered.

       For example, a frequently-run command like git checkout can be
       abbreviated to gco. After entering gco and pressing [${text_bold}Space${text_reset}],
       the full text git checkout will appear in the command line.

       To prevent expansion, press [${text_bold}CTRL-SPACE${text_reset}] in place of [${text_bold}SPACE${text_reset}].

   ${text_bold}Options${text_reset}
       The following options are available:

       o --add ABBREVIATION=EXPANSION or -a ABBREVIATION=EXPANSION Adds a new
         abbreviation, causing ABBREVIATION to be expanded to EXPANSION.

       o --clear-session or -E Erases all session abbreviations.

       o --erase ABBREVIATION or -e ABBREVIATION Erases the
         abbreviation ABBREVIATION.

       o --expand ABBREVIATION or -x ABBREVIATION Returns the abbreviation
         ABBREVIATION's EXPANSION.

       o --export-aliases [-g] [DESTINATION_FILE] or -o [-g] [DESTINATION_FILE]
         Exports a list of alias command for user abbreviations, suitable
         for pasting or piping to whereever you keep aliases. Add -g to export
         alias commands for session abbreviations. If a DESTINATION_FILE is
         provided, the commands will be appended to it.

       o --help or -h Show this documentation.

       o --import-aliases Adds abbreviations for all aliases.

       o --import-fish FILE Import from fish shell or zsh-abbr < 3.

       o --import-git-aliases Adds abbreviations for all git aliases.
         ABBREVIATIONs are prefixed with g, EXPANSIONs are prefixed
         with git[Space].

       o --list-abbreviations or -l Lists all ABBREVIATIONs.

       o --list-commands or -L (or fishy -s) Lists all abbreviations as
         commands suitable for export and import.

       o --list-definitions Lists all ABBREVIATIONs and their EXPANSIONs.

       o --rename OLD_ABBREVIATION NEW_ABBREVIATION
         or -R OLD_ABBREVIATION NEW_ABBREVIATION Renames an abbreviation,
         from OLD_ABBREVIATION to NEW_ABBREVIATION.

       o --version or -v Show the current version.

       In addition, when adding abbreviations, erasing, exporting aliases,
       [git] importing, or renaming use

       o --session or -S to create a session abbreviation, available only in
         the current session.

       o --user or -U to create a user abbreviation (default),
         immediately available to all sessions.

       and

       o --global or -g to create a global abbreviation, which expand anywhere
         on a line.

       and

       o --dry-run with add, import, or rename to see what the result would be.

       See the 'Internals' section for more on them.

   ${text_bold}Examples${text_reset}
       ${text_bold}abbr${text_reset} -a -g gco=\"git checkout\"
       ${text_bold}abbr${text_reset} --add --session gco=\"git checkout\"

         Add a new abbreviation where gco will be replaced with git checkout
         session to the current shell. This abbreviation will not be
         automatically visible to other shells unless the same command is run
         in those shells.

       ${text_bold}abbr${text_reset} -- g-=\"git checkout -\"

         If the EXPANSION includes a hyphen (-), the --add command\'s
         entire EXPANSION must be quoted.

       ${text_bold}abbr${text_reset} -a l=less
       ${text_bold}abbr${text_reset} --add l=less

         Add a new abbreviation where l will be replaced with less user so
         all shells. Note that you omit the -U since it is the default.

       ${text_bold}abbr${text_reset} -x gco
       \$(${text_bold}abbr${text_reset} -expand gco)

         Output the expansion for gco (in the above --add example,
         git checkout). Useful in scripting.

       ${text_bold}abbr${text_reset} --export-aliases -session

         Export alias declaration commands for each *session* abbreviation.
         Export lines look like alias -g <ABBREVIATION>='<EXPANSION>'

       ${text_bold}abbr${text_reset} --export-aliases

         Export alias declaration commands for each *user* abbreviation.
         Export lines look like alias -g <ABBREVIATION>='<EXPANSION>'

       ${text_bold}abbr${text_reset} --export-aliases ~/aliases

         Add alias definitions to ~/aliases

       ${text_bold}abbr${text_reset} -e -g gco
       ${text_bold}abbr${text_reset} --erase --session gco

         Erase the session gco abbreviation.

       ${text_bold}abbr${text_reset} -R -g gco gch
       ${text_bold}abbr${text_reset} --rename --session gco gch

         Rename the existing session abbreviation from gco to gch.

       ${text_bold}abbr${text_reset} -R l le
       ${text_bold}abbr${text_reset} --rename l le

        Rename the existing user abbreviation from l to le. Note that you
        can omit the -U since it is the default.

   ${text_bold}Internals${text_reset}
       The ABBREVIATION cannot contain IFS whitespace, comma (,), semicolon (;),
       pipe (|), or ampersand (&).

       Defining an abbreviation with session scope is slightly faster than
       user scope (which is the default).

       You can create abbreviations interactively and they will be visible to
       other zsh sessions if you use the -U flag or don't explicitly specify
       the scope. If you want it to be visible only to the current shell
       use the -g flag.

       The options add, export-aliases, erase, expand, import, list,
       list-commands, and rename are mutually exclusive, as are the session
       and user scopes.

       $version $release_date"
    version="zsh-abbr version 3.0.2"

    function add() {
      local abbreviation
      local expansion

      if [[ $# -gt 1 ]]; then
        util_error " add: Expected one argument, got $*"
        return
      fi

      abbreviation="${1%%=*}"
      expansion="${1#*=}"

      if [[ -z $abbreviation || -z $expansion || $abbreviation == $1 ]]; then
        util_error " add: Requires abbreviation and expansion"
        return
      fi

      util_add $abbreviation $expansion
    }

    function clear_session() {
      if [ $# -gt 0 ]; then
        util_error " clear-session: Unexpected argument"
        return
      fi

      ZSH_ABBR_SESSION_COMMANDS=()
      ZSH_ABBR_SESSION_GLOBALS=()
    }

    function erase() {
      local success=false

      if [ $# -gt 1 ]; then
        util_error " erase: Expected one argument"
        return
      elif [ $# -lt 1 ]; then
        util_error " erase: Erase needs a variable name"
        return
      fi

      if $opt_scope_session; then
        if $opt_type_global; then
          if (( ${+ZSH_ABBR_SESSION_GLOBALS[$1]} )); then
            unset "ZSH_ABBR_SESSION_GLOBALS[${(b)1}]"
            success=true
          fi
        elif (( ${+ZSH_ABBR_SESSION_COMMANDS[$1]} )); then
          unset "ZSH_ABBR_SESSION_COMMANDS[${(b)1}]"
          success=true
        fi
      else
        if $opt_type_global; then
          source "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"

          if (( ${+ZSH_ABBR_USER_GLOBALS[$1]} )); then
            unset "ZSH_ABBR_USER_GLOBALS[${(b)1}]"
            util_sync_user
            success=true
          fi
        else
          source "${TMPDIR:-/tmp}/zsh-user-abbreviations"

          if (( ${+ZSH_ABBR_USER_COMMANDS[$1]} )); then
            unset "ZSH_ABBR_USER_COMMANDS[${(b)1}]"
            util_sync_user
            success=true
          fi
        fi
      fi

      if ! $success; then
        util_error " erase: No matching abbreviation $1 exists"
      fi
    }

    function expand() {
      local expansion

      if [ $# -ne 1 ]; then
        printf "expand requires exactly one argument\\n"
        return
      fi

      expansion=$(_zsh_abbr_cmd_expansion "$1")

      if [[ ! -n "$expansion" ]]; then
        expansion=$(_zsh_abbr_global_expansion "$1")
      fi

      echo - "$expansion"
    }

    function export_aliases() {
      local source
      local alias_definition

      if [ $# -gt 1 ]; then
        util_error " export-aliases: Unexpected argument"
        return
      fi

      if $opt_scope_session; then
        util_alias ZSH_ABBR_SESSION_GLOBALS $1
        util_alias ZSH_ABBR_SESSION_COMMANDS $1
      else
        util_alias ZSH_ABBR_USER_GLOBALS $1
        util_alias ZSH_ABBR_USER_COMMANDS $1
      fi
    }

    function import_aliases() {
      local _alias

      if [ $# -gt 0 ]; then
        util_error " import-aliases: Unexpected argument"
        return
      fi

      while read -r _alias; do
        add $_alias
      done < <(alias -r)

      opt_type_global=true

      while read -r _alias; do
        add $_alias
      done < <(alias -g)

      if ! $opt_dry_run; then
        echo "Aliases imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function import_fish() {
      local abbreviation
      local expansion
      local input_file

      if [ $# -ne 1 ]; then
        printf "expand requires exactly one argument\\n"
        return
      fi

      input_file=$1

      while read -r line; do
        def=${line#* -- }
        abbreviation=${def%% *}
        expansion=${def#* }

        util_add $abbreviation $expansion
      done < $input_file

      if ! $opt_dry_run; then
        echo "Abbreviations imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function import_git_aliases() {
      local git_aliases
      local abbr_git_aliases

      if [ $# -gt 0 ]; then
        util_error " import-git-aliases: Unexpected argument"
        return
      fi

      git_aliases=("${(@f)$(git config --get-regexp '^alias\.')}")
      typeset -A abbr_git_aliases

      for i in $git_aliases; do
        key="${$(echo - $i | awk '{print $1;}')##alias.}"
        value="${$(echo - $i)##alias.$key }"

        util_add "g$key" "git ${value# }"
      done

      if ! $opt_dry_run; then
        echo "Aliases imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function list() {
      if [ $# -gt 0 ]; then
        util_error " list: Unexpected argument"
        return
      fi

      util_list 0
    }

    function list_commands() {
      if [ $# -gt 0 ]; then
        util_error " list commands: Unexpected argument"
        return
      fi

      util_list 2
    }

    function list_definitions() {
      if [ $# -gt 0 ]; then
        util_error " list definitions: Unexpected argument"
        return
      fi

      util_list 1
    }

    function print_version() {
      if [ $# -gt 0 ]; then
        util_error " version: Unexpected argument"
        return
      fi

      printf "%s\\n" "$version"
    }

    function rename() {
      local err
      local expansion

      if [ $# -ne 2 ]; then
        util_error " rename: Requires exactly two arguments"
        return
      fi

      if $opt_scope_session; then
        if $opt_type_global; then
          expansion=${ZSH_ABBR_SESSION_GLOBALS[$1]}
        else
          expansion=${ZSH_ABBR_SESSION_COMMANDS[$1]}
        fi
      else
        if $opt_type_global; then
          expansion=${ZSH_ABBR_USER_GLOBALS[$1]}
        else
          expansion=${ZSH_ABBR_USER_COMMANDS[$1]}
        fi
      fi

      if [[ -n "$expansion" ]]; then
        util_add $2 $expansion

        if ! $opt_dry_run; then
          erase $1
        else
          echo "abbr -e $1"
        fi
      else
        util_error " rename: No matching abbreviation $1 exists"
      fi
    }

    function util_add() {
      local abbreviation
      local abbreviation_last_word
      local expansion
      local quote
      local success=false

      abbreviation=$1
      expansion=$2
      quote="\""

      if [[ "${expansion:0:1}" == "${expansion: -1}" && "${expansion:0:1}" == [\'\"] ]]; then
        quote=${expansion:0:1}
        expansion="${expansion:1:-1}"
      fi

      if [[ ${(w)#abbreviation} > 1 ]]; then
        util_error " add: ABBREVIATION ('$abbreviation') must be only one word"
        return
      fi

      if [[ ${abbreviation%=*} != $abbreviation ]]; then
        util_error " add: ABBREVIATION ('$abbreviation') may not contain an equals sign"
      fi

      if $opt_scope_session; then
        if $opt_type_global; then
          if ! (( ${+ZSH_ABBR_SESSION_GLOBALS[$1]} )); then
            if $opt_dry_run; then
              echo "abbr -S -g $abbreviation=${quote}${expansion}${quote}"
            else
              ZSH_ABBR_SESSION_GLOBALS[$abbreviation]=$expansion
            fi
            success=true
          fi
        elif ! (( ${+ZSH_ABBR_SESSION_COMMANDS[$1]} )); then
          if $opt_dry_run; then
            echo "abbr -S $abbreviation=${quote}${expansion}${quote}"
          else
            ZSH_ABBR_SESSION_COMMANDS[$abbreviation]=$expansion
          fi
          success=true
        fi
      else
        if $opt_type_global; then
          source "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"

          if ! (( ${+ZSH_ABBR_USER_GLOBALS[$1]} )); then
            if $opt_dry_run; then
              echo "abbr -g $abbreviation=${quote}${expansion}${quote}"
            else
              ZSH_ABBR_USER_GLOBALS[$abbreviation]=$expansion
              util_sync_user $quote
            fi
            success=true
          fi
        else
          source "${TMPDIR:-/tmp}/zsh-user-abbreviations"

          if ! (( ${+ZSH_ABBR_USER_COMMANDS[$1]} )); then
            if $opt_dry_run; then
              echo "abbr $abbreviation=${quote}${expansion}${quote}"
            else
              ZSH_ABBR_USER_COMMANDS[$abbreviation]=$expansion
              util_sync_user $quote
            fi
            success=true
          fi
        fi
      fi

      if ! $success; then
        util_error " add: A matching abbreviation $1 already exists"
      fi
    }

    util_alias() {
      for abbreviation expansion in ${(kv)${(P)1}}; do
        alias_definition="alias "
        if [[ $opt_type_global == true ]]; then
          alias_definition+="-g "
        fi
        alias_definition+="$abbreviation='$expansion'"

        if [[ $# > 1 ]]; then
          echo "$alias_definition" >> "$1"
        else
          print "$alias_definition"
        fi
      done
    }

    function util_bad_options() {
      util_error ": Illegal combination of options"
    }

    function util_error() {
      printf "abbr%s\\nFor help run abbr --help\\n" "$@"
      should_exit=true
    }

    function util_list() {
      local result
      local include_expansion
      local include_cmd

      if [[ $1 > 0 ]]; then
        include_expansion=1
      fi

      if [[ $1 > 1 ]]; then
        include_cmd=1
      fi

      if ! $opt_scope_session; then
        if ! $opt_type_regular; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_USER_GLOBALS}; do
            util_list_item "$abbreviation" "$expansion" "abbr -g"
          done
        fi

        if ! $opt_type_global; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_USER_COMMANDS}; do
            util_list_item "$abbreviation" "$expansion" "abbr"
          done
        fi
      fi

      if ! $opt_scope_user; then
        if ! $opt_type_regular; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_SESSION_GLOBALS}; do
            util_list_item "$abbreviation" "$expansion" "abbr -S -g"
          done
        fi

        if ! $opt_type_global; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_SESSION_COMMANDS}; do
            util_list_item "$abbreviation" "$expansion" "abbr -S"
          done
        fi
      fi
    }

    function util_list_item() {
      local abbreviation
      local cmd
      local expansion

      abbreviation=$1
      expansion=$2
      cmd=$3

      result=$abbreviation
      if (( $include_expansion )); then
        result+="=\"$expansion\""
      fi

      if (( $include_cmd )); then
        result="$cmd $result"
      fi

      echo $result
    }

    function util_sync_user() {
      local quote
      local user_updated

      if [[ -n "$ZSH_ABBR_NO_SYNC_USER" ]]; then
        return
      fi

      quote="${1:-\"}"

      user_updated="${TMPDIR:-/tmp}/zsh-user-abbreviations"_updated
      rm "$user_updated" 2> /dev/null
      touch "$user_updated"
      chmod 600 "$user_updated"

      typeset -p ZSH_ABBR_USER_GLOBALS > "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"
      for abbreviation expansion in ${(kv)ZSH_ABBR_USER_GLOBALS}; do
        echo "abbr -g ${abbreviation}=${quote}$expansion${quote}" >> "$user_updated"
      done

      typeset -p ZSH_ABBR_USER_COMMANDS > "${TMPDIR:-/tmp}/zsh-user-abbreviations"
      for abbreviation expansion in ${(kv)ZSH_ABBR_USER_COMMANDS}; do
        echo "abbr ${abbreviation}=${quote}$expansion${quote}" >> "$user_updated"
      done

      mv "$user_updated" "$ZSH_ABBR_USER_PATH"
    }

    function util_type() {
      local type
      type="user"

      if $opt_scope_session; then
        type="session"
      fi

      echo $type
    }

    function util_usage() {
      print "$util_usage\\n"
    }

    for opt in "$@"; do
      if $should_exit; then
        should_exit=false
        return
      fi

      case "$opt" in
        "--add"|\
        "-a")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_add=true
          ((number_opts++))
          ;;
        "--clear-session"|\
        "-c")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_clear_session=true
          ((number_opts++))
          ;;
        --dry-run)
          opt_dry_run=true
          ((number_opts++))
          ;;
        "--erase"|\
        "-e")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_erase=true
          ((number_opts++))
          ;;
        "--expand"|\
        "-x")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_expand=true
          ((number_opts++))
          ;;
        "--global"|\
        "-g")
          [ "$type_set" = true ] && util_bad_options
          type_set=true
          opt_type_global=true
          ((number_opts++))
          ;;
        "--import-fish")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_import_fish=true
          ((number_opts++))
          ;;
        "--help"|\
        "-h")
          util_usage
          should_exit=true
          ;;
        "--import-git-aliases")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_import_git_aliases=true
          ((number_opts++))
          ;;
        "--export-aliases")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_export_aliases=true
          ((number_opts++))
          ;;
        "--import-aliases")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_import_aliases=true
          ((number_opts++))
          ;;
        "--list-abbreviations"|\
        "-l")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_list=true
          ((number_opts++))
          ;;
        "--list-commands"|\
        "-L"|\
        "--show"|\
        "-s") # "show" is for backwards compatability with v2
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_list_commands=true
          ((number_opts++))
          ;;
        "--regular"|\
        "-r")
          [ "$type_set" = true ] && util_bad_options
          type_set=true
          opt_type_regular=true
          ((number_opts++))
          ;;
        "--rename"|\
        "-R")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_rename=true
          ((number_opts++))
          ;;
        "--session"|\
        "-S")
          [ "$scope_set" = true ] && util_bad_options
          scope_set=true
          opt_scope_session=true
          ((number_opts++))
          ;;
        "--user"|\
        "-U")
          [ "$scope_set" = true ] && util_bad_options
          scope_set=true
          opt_scope_user=true
          ((number_opts++))
          ;;
        "--version"|\
        "-v")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_print_version=true
          ((number_opts++))
          ;;
        "--")
          ((number_opts++))
          break
          ;;
      esac
    done

    if $should_exit; then
      should_exit=false
      return
    fi

    shift $number_opts

    if $opt_add; then
       add "$@"
    elif $opt_clear_session; then
      clear_session "$@"
    elif $opt_erase; then
      erase "$@"
    elif $opt_expand; then
      expand "$@"
    elif $opt_export_aliases; then
      export_aliases "$@"
    elif $opt_import_aliases; then
      import_aliases "$@"
    elif $opt_import_fish; then
      import_fish "$@"
    elif $opt_import_git_aliases; then
      import_git_aliases "$@"
    elif $opt_list; then
      list "$@"
    elif $opt_list_commands; then
      list_commands "$@"
    elif $opt_print_version; then
      print_version "$@"
    elif $opt_rename; then
      rename "$@"

    # default if arguments are provided
    elif ! $opt_list_commands && [ $# -gt 0 ]; then
       add "$@"
    # default if no argument is provided
    else
      list_definitions "$@"
    fi
  } always {
    unfunction -m "add"
    unfunction -m "util_bad_options"
    unfunction -m "clear_session"
    unfunction -m "erase"
    unfunction -m "expand"
    unfunction -m "export_aliases"
    unfunction -m "import_aliases"
    unfunction -m "import_fish"
    unfunction -m "import_git_aliases"
    unfunction -m "list"
    unfunction -m "list_commands"
    unfunction -m "list_definitions"
    unfunction -m "print_version"
    unfunction -m "rename"
    unfunction -m "util_add"
    unfunction -m "util_alias"
    unfunction -m "util_error"
    unfunction -m "util_list"
    unfunction -m "util_list_item"
    unfunction -m "util_sync_user"
    unfunction -m "util_type"
    unfunction -m "util_usage"
  }
}

_zsh_abbr_bind_widgets() {
  # spacebar expands abbreviations
  zle -N _zsh_abbr_expand_and_space
  bindkey " " _zsh_abbr_expand_and_space

  # control-spacebar is a normal space
  bindkey "^ " magic-space

  # when running an incremental search,
  # spacebar behaves normally and control-space expands abbreviations
  bindkey -M isearch "^ " _zsh_abbr_expand_and_space
  bindkey -M isearch " " magic-space

  # enter key expands and accepts abbreviations
  zle -N _zsh_abbr_expand_and_accept
  bindkey "^M" _zsh_abbr_expand_and_accept
}

_zsh_abbr_cmd_expansion() {
  local abbreviation
  local expansion

  abbreviation="$1"
  expansion="${ZSH_ABBR_SESSION_COMMANDS[$1]}"

  if [[ ! -n "$expansion" ]]; then
    source "${TMPDIR:-/tmp}/zsh-user-abbreviations"
    expansion="${ZSH_ABBR_USER_COMMANDS[$1]}"
  fi

  echo - "$expansion"
}

_zsh_abbr_expand_and_accept() {
  local trailing_space
  trailing_space=${LBUFFER##*[^[:IFSSPACE:]]}

  if [[ -z $trailing_space ]]; then
    zle _zsh_abbr_expand_widget
  fi

  zle accept-line
}

_zsh_abbr_expand_and_space() {
  zle _zsh_abbr_expand_widget
  zle self-insert
}

_zsh_abbr_global_expansion() {
  local abbreviation
  local expansion

  abbreviation="$1"
  expansion="${ZSH_ABBR_SESSION_GLOBALS[$1]}"

  if [[ ! -n "$expansion" ]]; then
    source "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"
    expansion="${ZSH_ABBR_USER_GLOBALS[$1]}"
  fi

  echo - "$expansion"
}

_zsh_abbr_init() {
  local line
  local session_shwordsplit_on

  session_shwordsplit_on=false
  ZSH_ABBR_NO_SYNC_USER=true

  typeset -gA ZSH_ABBR_USER_COMMANDS
  typeset -gA ZSH_ABBR_SESSION_COMMANDS
  typeset -gA ZSH_ABBR_USER_GLOBALS
  typeset -gA ZSH_ABBR_SESSION_GLOBALS
  ZSH_ABBR_USER_COMMANDS=()
  ZSH_ABBR_SESSION_COMMANDS=()
  ZSH_ABBR_USER_GLOBALS=()
  ZSH_ABBR_SESSION_GLOBALS=()

  if [[ $options[shwordsplit] = on ]]; then
    session_shwordsplit_on=true
  fi

  # prevent collisions with other initializing sessions
  while [ -f "${TMPDIR:-/tmp}/zsh-abbr-initializing" ]; do
    sleep 0.01
  done

  touch "${TMPDIR:-/tmp}/zsh-abbr-initializing"
  chmod 600 "${TMPDIR:-/tmp}/zsh-user-abbreviations"

  # Scratch files
  rm "${TMPDIR:-/tmp}/zsh-user-abbreviations" 2> /dev/null
  touch "${TMPDIR:-/tmp}/zsh-user-abbreviations"
  chmod 600 "${TMPDIR:-/tmp}/zsh-user-abbreviations"

  rm "${TMPDIR:-/tmp}/zsh-user-global-abbreviations" 2> /dev/null
  touch "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"
  chmod 600 "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"

  # Load saved user abbreviations
  if [ -f "$ZSH_ABBR_USER_PATH" ]; then
    unsetopt shwordsplit

    source "$ZSH_ABBR_USER_PATH"

    if $session_shwordsplit_on; then
      setopt shwordsplit
    fi
  else
    mkdir -p $(dirname "$ZSH_ABBR_USER_PATH")
    touch "$ZSH_ABBR_USER_PATH"
  fi

  unset ZSH_ABBR_NO_SYNC_USER

  typeset -p ZSH_ABBR_USER_COMMANDS > "${TMPDIR:-/tmp}/zsh-user-abbreviations"
  typeset -p ZSH_ABBR_USER_GLOBALS > "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"

  rm "${TMPDIR:-/tmp}/zsh-abbr-initializing"
}

# WIDGETS
# -------

_zsh_abbr_expand_widget() {
  local expansion
  local word
  local words
  local word_count

  words=(${(z)LBUFFER})
  word=$words[-1]
  word_count=${#words}

  if [[ $word_count == 1 ]]; then
    expansion=$(_zsh_abbr_cmd_expansion "$word")
  fi

  if ! [[ -n "$expansion" ]]; then
    expansion=$(_zsh_abbr_global_expansion "$word")
  fi

  if [[ -n "$expansion" ]]; then
    local preceding_lbuffer
    preceding_lbuffer="${LBUFFER%%$word}"
    LBUFFER="$preceding_lbuffer$expansion"
  fi
}

zle -N _zsh_abbr_expand_widget


# SHARE
# -----

abbr() {
  _zsh_abbr $*
}


# INITIALIZATION
# --------------

_zsh_abbr_init

if [ "$ZSH_ABBR_DEFAULT_BINDINGS" = true ]; then
  _zsh_abbr_bind_widgets
fi

