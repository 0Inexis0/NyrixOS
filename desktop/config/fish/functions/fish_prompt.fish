function fish_prompt --description 'Compact NyrixOS prompt'
    set -l last_status $status
    set_color a7ede1
    printf '%s' (prompt_pwd)
    set_color c4b5e8
    printf '%s' (fish_git_prompt)
    printf '\n'
    if test $last_status -eq 0
        set_color a7ede1
    else
        set_color ef9fa9
        printf '[%s] ' $last_status
    end
    printf '❯ '
    set_color normal
end
