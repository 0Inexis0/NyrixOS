function fish_greeting --description 'NyrixOS terminal welcome'
    # Greeting is called by interactive fish only; never print in scripts.
    if status is-interactive; and command -q fastfetch
        printf '\n'
        if string match -q 'de*' -- "$LANG"
            command fastfetch --config "$HOME/.config/fastfetch/config.de.json"
        else
            command fastfetch
        end
        printf '\n'
    end
end
