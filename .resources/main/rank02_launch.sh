#!/bin/bash
# rank02_launch.sh - prompts for order mode then launches level_base.sh
source colors.sh

level=$1

clear
printf "${CYAN}─────────────────────────────────────────────────────────────${RESET}\n"
printf "${YELLOW}${BOLD}%s${RESET}\n" "1. 🔀 Random order"
printf "${YELLOW}${BOLD}%s${RESET}\n" "2. 📋 In order (as listed in the level)"
printf "${CYAN}─────────────────────────────────────────────────────────────${RESET}\n"
printf "${GREEN}${BOLD}Order mode (1/2, default random): ${RESET}"
read -r order_opt

case $order_opt in
    2) export EXAM_ORDER="ordered" ;;
    *) export EXAM_ORDER="random" ;;
esac

bash level_base.sh rank02 "$level"
