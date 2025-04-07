#!/bin/bash

# Navigate to /tmp directory
cd /tmp || { echo -e "${RED}Failed to navigate to /tmp.${NC}"; exit 1; }

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PINK='\033[1;35m'
NC='\033[0m' # No Color

# Set repository URL and local directory
REPO_URL="https://github.com/GlitchLinux/gLiTcH-ToolKit.git"
LOCAL_DIR="gLiTcH-ToolKit"

# Clone or update repository
if [ -d "$LOCAL_DIR/.git" ]; then
    echo -e "${YELLOW}Updating repository...${NC}"
    git -C "$LOCAL_DIR" pull || { echo -e "${RED}Failed to update repository.${NC}"; exit 1; }
else
    echo -e "${YELLOW}Cloning repository...${NC}"
    git clone "$REPO_URL" "$LOCAL_DIR" || { echo -e "${RED}Failed to clone repository.${NC}"; exit 1; }
fi

# Main loop
while true; do
    clear

    # Display banner with proper alignment
    echo -e "${PINK}"
    printf "${PINK}│ ${CYAN}%-53s${PINK}│\n" "gLiTcH-ToolKit - Linux System Tools"
    echo -e ${NC}"
    echo ""

    # Get sorted list of tools (case-insensitive) excluding hidden files
    mapfile -t entries < <(find "$LOCAL_DIR" -mindepth 1 -maxdepth 1 -not -path "*/.git*" -type f -printf "%f\n" | sort -f)

    # Check if any tools are available
    if [ ${#entries[@]} -eq 0 ]; then
        echo -e "${RED}No tools found in the repository.${NC}"
        sleep 2
        continue
    fi

    # Display tools in 3 columns with dynamic alignment
    count=1
    max_width=35 # Maximum width for each column
    for entry in "${entries[@]}"; do
        printf "${GREEN}%3d. ${CYAN}%-*s${NC}" "$count" "$max_width" "$entry"
        if (( count % 3 == 0 )); then
          e  echo ""
        fi
        ((count++))
    done
    [[ $(( (count-1) % 3 )) != 0 ]] && echo ""  # Add newline if last row incomplete

    echo ""
    echo -e -n "${YELLOW}Enter a number to execute (1-${#entries[@]}), or 0 to quit:${NC}"
    read -r choice
    echo -e "${YELLOW}${choice}${NC}]"

    # Handle user input
    if [[ "$choice" == "0" ]]; then
        echo -e "${RED}Exiting.${NC}"
        break
    elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#entries[@]} )); then
        selected="$LOCAL_DIR/${entries[$((choice-1))]}"
        if [ -x "$selected" ]; then
            echo -e "${YELLOW}Executing ${CYAN}$selected${NC}..."
            "$selected"
        else
            echo -e "${RED}File is not executable. Running with bash...${NC}"
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
echo -e "${YELLOW}Cleaning up...${NC}"
rm -rf "/tmp/$LOCAL_DIR" || echo -e "${RED}Failed to clean up temporary files.${NC}"
