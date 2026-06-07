#!/bin/bash
source functions.sh
source colors.sh

rank=$1
shift
order=${@: -1}
all_args=("$@")
unset 'all_args[${#all_args[@]}-1]'
IFS=' ' read -ra chosen_entries <<< "${all_args[*]}"

base_dir="$(cd "$(dirname "$0")" && pwd)"

if [[ "${EXAMSHELL_LANG:-}" == "en" ]]; then
    LANG_LABEL="🌐 EN"
else
    LANG_LABEL="🌐 JP"
fi

order_label="🔀 Random"
[[ "$order" == "ordered" ]] && order_label="📋 Ordered"

if [[ "$order" == "random" ]]; then
    size=${#chosen_entries[*]}
    max=$(( 32768 / size * size ))
    for ((i = size - 1; i > 0; i--)); do
        while (( (rand = RANDOM) >= max )); do :; done
        rand=$(( rand % (i + 1) ))
        tmp=${chosen_entries[i]}
        chosen_entries[i]=${chosen_entries[rand]}
        chosen_entries[rand]=$tmp
    done
fi

num=${#chosen_entries[@]}
i=0

declare -A passed_flags

score_summary() {
    local total=0
    for k in "${!passed_flags[@]}"; do
        [[ "${passed_flags[$k]}" == "1" ]] && total=$((total + 1))
    done
    echo "$total"
}

SESSION_START=$SECONDS
format_time() {
    local e=$(( SECONDS - SESSION_START ))
    printf "%02d:%02d:%02d" $((e/3600)) $(((e%3600)/60)) $((e%60))
}

setup_rendu() {
    local rank=$1 level=$2 ex=$3
    mkdir -p "$base_dir/../../rendu/$ex"
    if [[ "$rank" == "rank03" && "$level" == "level1" ]]; then
        if [[ "$ex" == "broken_gnl" ]]; then
            [ -f "broken_gnl.c" ] && cp "broken_gnl.c" "$base_dir/../../rendu/$ex/"
            touch "$base_dir/../../rendu/$ex/get_next_line.c"
            touch "$base_dir/../../rendu/$ex/get_next_line.h"
        elif [[ "$ex" == "scanf" ]]; then
            touch "$base_dir/../../rendu/$ex/ft_scanf.c"
        else
            touch "$base_dir/../../rendu/$ex/${ex}.c"
        fi
    elif [[ "$rank" == "rank03" && "$level" == "level2" ]]; then
        [[ "$ex" == "tsp" && -f "tsp.c" ]] && cp "tsp.c" "$base_dir/../../rendu/$ex/"
    elif [[ "$rank" == "rank04" && "$level" == "level2" ]]; then
        [ -f "given.c" ] && cp "given.c" "$base_dir/../../rendu/$ex/"
        touch "$base_dir/../../rendu/$ex/${ex}.c"
        [[ "$ex" == "vbc" ]] && touch "$base_dir/../../rendu/$ex/vbc.h"
    else
        touch "$base_dir/../../rendu/$ex/${ex}.c"
    fi
}

clear_rendu() {
    local rendu_dir="$base_dir/../../rendu"
    if [ -d "$rendu_dir" ]; then
        printf "${YELLOW}${BOLD}Backup before clearing? [y/n]: ${RESET}"
        read -r backup_choice
        if [[ "$backup_choice" == "y" || "$backup_choice" == "Y" ]]; then
            mkdir -p "$base_dir/../../trace"
            cp -r "$rendu_dir" "$base_dir/../../trace/rendu_backup_$(date +%s)"
            echo -e "${GREEN}Backup saved to trace/.${RESET}"
        fi
        rm -rf "$rendu_dir"/*
        echo -e "${GREEN}Rendu cleared.${RESET}"
    else
        echo -e "${YELLOW}Rendu is already empty.${RESET}"
    fi
    sleep 1
}

finish_session() {
    local passed=$(score_summary)
    clear
    printf "${CYAN}╔═══════════════════════════════════════════════════════════╗${RESET}\n"
    printf "${BLUE}║${GREEN}                  🏁 Session Complete!                  ${BLUE}║${RESET}\n"
    printf "${CYAN}╚═══════════════════════════════════════════════════════════╝${RESET}\n"
    echo ""
    printf "  Score:  ${GREEN}${BOLD}%d / %d${RESET}\n" "$passed" "$num"
    printf "  Time:   ${GREEN}%s${RESET}\n" "$(format_time)"
    printf "  Mode:   ${YELLOW}Custom (cross-level)${RESET}\n"
    printf "  Order:  ${MAGENTA}%s${RESET}\n" "$order_label"
    echo ""
    printf "  ${GREEN}Passed:${RESET}\n"
    for entry in "${chosen_entries[@]}"; do
        if [[ "${passed_flags[$entry]:-}" == "1" ]]; then
            lvl="${entry%%:*}"; ex="${entry##*:}"
            printf "    ${GREEN}✓${RESET} %-10s  %s\n" "[$lvl]" "$ex"
        fi
    done
    echo ""
    printf "  ${RED}Not passed:${RESET}\n"
    for entry in "${chosen_entries[@]}"; do
        if [[ "${passed_flags[$entry]:-}" != "1" ]]; then
            lvl="${entry%%:*}"; ex="${entry##*:}"
            printf "    ${RED}✗${RESET} %-10s  %s\n" "[$lvl]" "$ex"
        fi
    done
    echo ""
    printf "${CYAN}─────────────────────────────────────────────────────────────${RESET}\n"
    read -rp "$(printf "${GREEN}${BOLD}Press enter to go back.${RESET}")" _
    cd "$base_dir"
    bash rank02_menu.sh
    exit
}

while true; do
    entry="${chosen_entries[$i]}"
    level="${entry%%:*}"
    ex="${entry##*:}"

    cd "$base_dir/../$rank/$level/$ex"
    setup_rendu "$rank" "$level" "$ex"
    subject=$(read_subject_text)

    while true; do
        clear
        passed_now=$(score_summary)
        already_passed=""
        [[ "${passed_flags[$entry]:-}" == "1" ]] && already_passed=" ${GREEN}✓${RESET}"
        printf "${CYAN}[%s]${RESET}%b" "$ex" "$already_passed"
        printf "  ${YELLOW}(%d/%d)${RESET}" $((i + 1)) $num
        printf "  ${GREEN}Score: %d/%d${RESET}" "$passed_now" "$num"
        printf "  ${MAGENTA}[%s]${RESET}" "$level"
        printf "  ${BLUE}$LANG_LABEL${RESET}"
        printf "  ${MAGENTA}$order_label${RESET}"
        printf "  ${GREEN}⏱ %s${RESET}\n" "$(format_time)"
        echo -e "${WHITE}$subject${RESET}"
        echo
        if [[ $i -gt 0 ]]; then
            echo "Commands: 'test' | 'next' | 'back' | 'clear-rendu' | 'menu' | 'exit'"
        else
            echo "Commands: 'test' | 'next' | 'clear-rendu' | 'menu' | 'exit'"
        fi
        echo
        read -rp "/>" input

        case $input in
            next)
                i=$((i + 1))
                [ $i -ge $num ] && finish_session
                break
                ;;
            back)
                if [[ $i -gt 0 ]]; then
                    i=$((i - 1))
                    break
                else
                    echo "Already at the first exercise."
                    sleep 0.8
                fi
                ;;
            test)
                clear
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    script -q /tmp/tester_out.txt ./tester.sh
                else
                    script -q -c "./tester.sh" /tmp/tester_out.txt
                fi
                read -rp "${GREEN}${BOLD}Please press enter to continue.${RESET}" _
                if grep -q "PASSED" /tmp/tester_out.txt; then
                    passed_flags["$entry"]=1
                    i=$((i + 1))
                    [ $i -ge $num ] && finish_session
                fi
                break
                ;;
            clear-rendu)
                clear_rendu
                ;;
            menu)
                cd "$base_dir"
                bash rank02_menu.sh
                exit
                ;;
            exit)
                cd "$base_dir/../../"
                if [ -d rendu ]; then
                    mkdir -p trace
                    cp -r rendu "trace/rendu_backup_$(date +%s)"
                    rm -rf rendu
                fi
                exit 1
                ;;
            *)
                echo "Unknown command."
                sleep 0.6
                ;;
        esac
    done
done
