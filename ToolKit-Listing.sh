#!/bin/bash
cd /tmp

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PINK='\033[1;35m'
NC='\033[0m'

# Set repo URL and local directory
REPO_URL="https://github.com/GlitchLinux/gLiTcH-ToolKit.git"
LOCAL_DIR="gLiTcH-ToolKit"

# Clone or update repository
if [ -d "$LOCAL_DIR/.git" ]; then
    echo -e "${YELLOW}Updating repository...${NC}"
    git -C "$LOCAL_DIR" pull
else
    echo -e "${YELLOW}Cloning repository...${NC}"
    git clone "$REPO_URL" "$LOCAL_DIR"
fi

while true; do
    clear
    # Clean banner display
    echo -e "${PINK}┌───────────────────────────────────────────────────────┐"
    echo -e "│ ${CYAN}gLiTcH-ToolKit - Linux System Tools ${PINK}               │"
    echo -e "└───────────────────────────────────────────────────────┘${NC}"
    echo ""

    # Get sorted list of tools (case-insensitive)
    mapfile -t entries < <(find "$LOCAL_DIR" -mindepth 1 -maxdepth 1 -not -path "*/.git*" -printf "%f\n" | sort -f)
    
    # Display in 4 columns
    count=1
    for entry in "${entries[@]}"; do
        printf "${GREEN}%3d. ${PINK}%-30s${NC}" "$count" "$entry"
        if (( count % 4 == 0 )); then
            echo ""
        fi
        ((count++))
    done
    [[ $(( (count-1) % 4 )) != 0 ]] && echo ""  # Add newline if last row incomplete

    echo ""
    echo -e "${YELLOW}Enter a number to execute (1-${#entries[@]}), or 0 to quit:${NC} "
    read -r choice

    if [[ "$choice" == "0" ]]; then
        echo -e "${RED}Exiting.${NC}"
        break
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#entries[@]} )); then
        selected="$LOCAL_DIR/${entries[$((choice-1))]}"
        if [ -x "$selected" ]; then
            echo -e "${YELLOW}Executing ${CYAN}$selected${NC}..."
            "$selected"
        else
            echo -e "${RED}Running with bash...${NC}"
            bash "$selected"
        fi
        echo -e "\n${BLUE}Press Enter to continue...${NC}"
        read -r
    else
        echo -e "${RED}Invalid selection!${NC}"
        sleep 1
    fi
done

# Cleanup
rm -rf "/tmp/$LOCAL_DIR"
