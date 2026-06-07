#!/bin/bash
source colors.sh

if [[ "${EXAMSHELL_LANG:-}" == "en" ]]; then
    lang_status="${GREEN}English 🌐${RESET}"
    lang_toggle_label="Switch to Japanese / 日本語に切り替え"
else
    lang_status="${GREEN}日本語 🌐${RESET}"
    lang_toggle_label="Switch to English / 英語に切り替え"
fi

clear
printf "${CYAN}%s${RESET}\n" "╔═══════════════════════════════════════════════════════════╗"
printf "${BLUE}%s${GREEN}%s${BLUE}%s${RESET}\n" "║" "            📄 EXAM RANK 02 - MODE SELECTION            " "║"
printf "${CYAN}%s${RESET}\n" "╚═══════════════════════════════════════════════════════════╝"
printf "  Language / 言語: %b\n" "$lang_status"
printf "${CYAN}%s${RESET}\n" "───────────────────────────────────────────────────────────"
printf "${YELLOW}${BOLD}%s${RESET}\n" "1. Level Mode"
printf "${YELLOW}${BOLD}%s${RESET}\n" "2. Real Exam Mode"
printf "${YELLOW}${BOLD}%s${RESET}\n" "3. Custom Picker Mode  (mix exercises across levels)"
printf "${YELLOW}${BOLD}%s${RESET}\n" "4. $lang_toggle_label"
printf "${YELLOW}${BOLD}%s${RESET}\n" "5. Clear Rendu"
printf "${YELLOW}${BOLD}%s${RESET}\n" "6. Back to Main Menu"
printf "${CYAN}%s${RESET}\n" "───────────────────────────────────────────────────────────"
printf "${GREEN}${BOLD}Enter your choice (1-6): ${RESET}"
read rank02_opt

case $rank02_opt in
    1)
        bash rank02.sh
        ;;
    2)
        bash rank02_real_mode.sh
        ;;
    3)
        bash custom_picker.sh rank02
        ;;
    4)
        if [[ "${EXAMSHELL_LANG:-}" == "en" ]]; then
            export EXAMSHELL_LANG="jp"
        else
            export EXAMSHELL_LANG="en"
        fi
        bash rank02_menu.sh
        ;;
    5)
        rendu_dir="$(cd "$(dirname "$0")" && pwd)/../../rendu"
        if [ -d "$rendu_dir" ]; then
            printf "${YELLOW}${BOLD}Backup before clearing? [y/n]: ${RESET}"
            read -r backup_choice
            if [[ "$backup_choice" == "y" || "$backup_choice" == "Y" ]]; then
                mkdir -p "$(cd "$(dirname "$0")" && pwd)/../../trace"
                cp -r "$rendu_dir" "$(cd "$(dirname "$0")" && pwd)/../../trace/rendu_backup_$(date +%s)"
                echo -e "${GREEN}Backup saved to trace/.${RESET}"
            fi
            rm -rf "$rendu_dir"/*
            echo -e "${GREEN}Rendu cleared.${RESET}"
        else
            echo -e "${YELLOW}Rendu is already empty.${RESET}"
        fi
        sleep 1
        bash rank02_menu.sh
        ;;
    6)
        bash intro.sh
        ;;
    *)
        echo "Invalid choice."
        sleep 1
        bash rank02_menu.sh
        ;;
esac
