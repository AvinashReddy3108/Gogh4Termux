#!/usr/bin/env bash
tmp_IFS=$IFS

_require () {
    for pkg in "$@"
    do
        command -v $pkg >/dev/null 2>&1 || { echo >&2 "I require '$pkg' but it's not installed. Aborting."; exit 1; }
    done
}

_require jq curl fzf

# Get themes
status_code=$(curl -I "https://github.com/AvinashReddy3108/Gogh4Termux" 2>&1 | awk '/HTTP\// {print $2}')
if [ "$status_code" -eq "200" ]; then
    echo "Fetching themes list from repository, please wait."
    theme=$(curl -fSsL https://api.github.com/repos/AvinashReddy3108/Gogh4Termux/git/trees/master | jq -r '.tree[] | select (.path | contains(".properties")) | .path' | fzf)
    if [ $? -eq 0 ]; then
        echo "Applying color scheme: $theme"
        mkdir -p ~/.termux
        if curl -fsSL "https://raw.githubusercontent.com/AvinashReddy3108/Gogh4Termux/master/$theme" -o ~/.termux/colors.properties; then
            termux-reload-settings
            if [ $? -ne 0 ]; then
                echo "Failed to apply color scheme."
            fi
        else
            echo "Failed to download color scheme."
        fi
    else
        echo "Cancelled color scheme selection."
    fi
else
    echo "Make sure you're connected to the internet!"
    exit 1
fi
