# -----------------------------------------------------------------------------
#          FILE: bash.zsh-theme
#   DESCRIPTION: oh-my-zsh theme file, based on smt by Stephen Tudor.
#        AUTHOR: Andras Tim (andras.tim@gmail.com)
#       VERSION: 0.1
#    SCREENSHOT: coming soon
# -----------------------------------------------------------------------------

MODE_INDICATOR="%{$fg_bold[red]%}❮%{$reset_color%}%{$fg[red]%}❮❮%{$reset_color%}"
local return_status="%{$fg[red]%}%(?..[%?] )%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_SHORTPATH_LENGTH=30

ZSH_THEME_GIT_PROMPT_PREFIX="|"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[red]%}⚡%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[red]%}!%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} +"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} *"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ="
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} u"

# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="➤ %{$fg_bold[yellow]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%}"

function prompt_char()
{
    git branch >/dev/null 2>/dev/null && echo "±" && return
    hg root >/dev/null 2>/dev/null && echo "☿" && return
    echo "$"
}

function shortpath()
{
    full_path="${1/#$HOME/~}"
    path_length=${#full_path}

    local IFS=/
    path_array=("${(s>/>)full_path}")
    array_count=$[${#path_array[*]}]

    i=2
    while ((path_length>$2 && i<$array_count))
    do
        item=${path_array[i]}
        item_length=${#item}
        n=1; [[ $item = .* ]] && n=2
        path_length=$[ $path_length - $item_length - $n ]
        path_array[i++]=${item:0:$n}
    done
    [[ "${path_array[2]}" == '' ]] && path_array[0]='/'
    echo "${path_array[*]}"
}

function scm_base_info()
{
    # SCM: GIT
    local base="$(git rev-parse --show-toplevel 2>/dev/null)"
    local scm_user="$(git config user.email | sed 's>^[^@]*>>')"

    # SCM: HG (Mercurial)
    if [[ "${base}" == '' ]]; then
        base="$(hg root 2>/dev/null)"
        scm_user=''
    fi

    [[ "${scm_user}" != '' ]] && scm_user=":%{$fg_bold[blue]%}${scm_user}%{$reset_color%}"

    # if exists then returns with $base
    if [[ "${base}" != '' ]] && [[ -e "${base}" ]]; then
        echo "(%{$fg[cyan]%}$(shortpath "${base}" ${ZSH_THEME_GIT_PROMPT_SHORTPATH_LENGTH})%{$reset_color%}${scm_user}) "
    fi
}

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[cyan]%}"

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit()
{
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Only proceed if there is actually a commit.
        if [[ $(git log -1 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
            # Get the last commit.
            last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
            now=`date +%s`
            seconds_since_last_commit=$((now-last_commit))

            # Totals
            MINUTES=$((seconds_since_last_commit / 60))
            HOURS=$((seconds_since_last_commit/3600))

            # Sub-hours and sub-minutes
            DAYS=$((seconds_since_last_commit / 86400))
            SUB_HOURS=$((HOURS % 24))
            SUB_MINUTES=$((MINUTES % 60))

            if [[ -n $(git status -s 2> /dev/null) ]]; then
                if [ "$MINUTES" -gt 30 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
                elif [ "$MINUTES" -gt 10 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
                else
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
                fi
            else
                COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            fi

            if [ "$HOURS" -gt 24 ]; then
                echo "[$COLOR${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m%{$reset_color%}]"
            elif [ "$MINUTES" -gt 60 ]; then
                echo "[$COLOR${HOURS}h${SUB_MINUTES}m%{$reset_color%}]"
            else
                echo "[$COLOR${MINUTES}m%{$reset_color%}]"
            fi
        else
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            echo "[$COLOR~]"
        fi
    fi
}

if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi

PROMPT='%{$reset_color%}%{$fg_bold[$NCOLOR]%}%n@%m%{$reset_color%}:%{$fg_bold[blue]%}%~%{$reset_color%}%{$fg_bold[gray]%}$(prompt_char) %{$reset_color%}'
RPROMPT='${return_status}$(scm_base_info)$(git_time_since_commit)$(git_prompt_status) %{$reset_color%}$(git_prompt_short_sha)$(git_prompt_info)'
