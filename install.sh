#!/usr/bin/env bash
tmp_IFS=$IFS

# Get themes
status_code=$(curl -IL https://github.com/AvinashReddy3108/Gogh4Termux 2>/dev/null | head -n 1 | cut -d$' ' -f2)
if [ "$status_code" -eq "200" ]; then
    themes=$(curl -sL https://github.com/AvinashReddy3108/Gogh4Termux | grep -o "title=.*\.properties\" " | awk -F '=' '{print $2}' | tr -d '"')
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
        fi
    else
        echo "Failed to download/apply color scheme."
    fi
fi
