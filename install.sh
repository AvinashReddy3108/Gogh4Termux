#!/usr/bin/env bash
tmp_IFS=$IFS

_require () {
    for pkg in "$@"
    do
        command -v $pkg >/dev/null 2>&1 || { echo >&2 "I require '$pkg' but it's not installed. Aborting."; exit 1; }
    done
}

_require jq curl dialog

# Get themes
status_code=$(curl -I "https://github.com/AvinashReddy3108/Gogh4Termux" 2>&1 | awk '/HTTP\// {print $2}')
if [ "$status_code" -eq "200" ]; then
    themes=$(curl -fSsL https://api.github.com/repos/AvinashReddy3108/Gogh4Termux/git/trees/master | jq -r '.tree[] | select (.path | contains(".properties")) | .path')
    IFS=$'\n'
    names=($themes)
    FILES=()
    for (( i=0; i<${#names[@]}; i++ ))
    do
        FILES+=("$i" "${names[$i]}")
    done
    IFS=$tmp_IFS
else
    echo "Make sure you're connected to the internet!"
    exit 1
fi

# Build the menu with dynamic content
TERMINAL=$(tty) # Gather current terminal session for appropriate redirection
TITLE="Gogh4Termux - Color Scheme chooser"
MENU="Choose a color scheme from the list below."

CHOICE=$(whiptail --title "$TITLE" --menu "$MENU" 0 0 0 ${FILES[@]} 3>&1 1>&2 2>&3 > $TERMINAL)

if [ $? -eq 0 ]; then
    clear
    echo "Applying color scheme: ${names[$CHOICE]}"
    mkdir -p ~/.termux
    if curl -fsSL -o ~/.termux/colors.properties "https://raw.githubusercontent.com/AvinashReddy3108/Gogh4Termux/master/${names[$CHOICE]}"; then
        termux-reload-settings
        if [ $? -eq 0 ]; then
            clear
        else
            echo "Failed to apply color scheme."
        fi
    else
        echo "Failed to download color scheme."
    fi
fi
