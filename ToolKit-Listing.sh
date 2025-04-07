#!/bin/bash

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PINK='\033[1;35m'  # Bright Pink
NC='\033[0m'      # No Color (reset)

# Set repo URL and local directory
REPO_URL="https://github.com/GlitchLinux/gLiTcH-ToolKit.git"
LOCAL_DIR="gLiTcH-ToolKit"

# Clone or update the repository
if [ -d "$LOCAL_DIR/.git" ]; then
    echo -e "${YELLOW}Updating repository...${NC}"
    git -C "$LOCAL_DIR" pull
else
    echo -e "${YELLOW}Cloning repository...${NC}"
    git clone "$REPO_URL" "$LOCAL_DIR"
fi

while true; do
    # Clear screen before showing menu
    clear
    
    # Display header
    echo -e "${PINK}┌──────────────────────────────────────────────────────┐"
    echo -e "│ ${CYAN} gLiTcH-ToolKit - Linux System Tools ${PINK}         │"
    echo -e "└───────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Collect entries and sort alphabetically (case-insensitive)
    entries=()
    while IFS= read -r entry; do
        entries+=("$entry")
    done < <(find "$LOCAL_DIR" -mindepth 1 -not -path "*/.git*" -printf "%P\n" | sort -f)

    # Determine terminal width and calculate column layout
    terminal_width=$(tput cols)
    max_entry_length=$(printf "%s\n" "${entries[@]}" | awk '{print length}' | sort -nr | head -n1)
    column_width=$((max_entry_length + 4)) # Add padding for spacing
    num_columns=$((terminal_width / column_width))
    num_columns=$((num_columns < 1 ? 1 : num_columns)) # Ensure at least one column

    # Print entries in multi-column format
    count=1
    for entry in "${entries[@]}"; do
        printf "${GREEN}%3d. ${PINK}%-*s${NC}" "$count" "$column_width" "$entry"
        if (( count % num_columns == 0 )); then
            echo "" # Newline after every row
        fi
        ((count++))
    done
    echo "" # Ensure final newline

    # Prompt user for selection
    echo " "
    echo -e "${YELLOW}Enter a number to execute the corresponding file, or '0' to quit:${NC} "
    read -r choice

    # Exit if user chooses 0
    if [[ "$choice" == "0" ]]; then
        echo -e "${RED}Exiting.${NC}"
        break
    fi

    # Execute selected file if valid
    if [[ -n "$choice" && -n "${entries[$((choice-1))]}" ]]; then
        selected_file="$LOCAL_DIR/${entries[$((choice-1))]}"
        if [ -x "$selected_file" ]; then
            echo -e "${YELLOW}Executing ${CYAN}$selected_file${NC}..."
            "$selected_file"
        else
            echo -e "${RED}Selected file is not executable. Attempting to run with bash...${NC}"
            bash "$selected_file"
        fi
        echo -e "\n${BLUE}Press Enter to return to menu...${NC}"
        read -r
    else
        echo -e "${RED}Invalid selection. Please try again.${NC}"
        sleep 1
    fi
done
