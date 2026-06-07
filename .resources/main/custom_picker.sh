#!/bin/bash
source functions.sh
source colors.sh

rank=$1

declare -A level_exercises
if [[ "$rank" == "rank02" ]]; then
    level_exercises["level0"]="first_word fizzbuzz ft_putstr ft_strcpy ft_strlen ft_swap repeat_alpha rev_print rot_13 rotone search_and_replace ulstr"
    level_exercises["level1"]="alpha_mirror camel_to_snake print_bits do_op ft_atoi ft_strcmp reverse_bits ft_strrev ft_strcspn ft_strdup inter is_power_of_2 last_word max snake_to_camel swap_bits union wdmatch ft_strpbrk ft_strspn"
    level_exercises["level2"]="add_prime_sum epur_str expand_str ft_list_size ft_atoi_base ft_range ft_rrange hidenp lcm paramsum pgcd print_hex rstr_capitalizer str_capitalizer tab_mult"
    level_exercises["level3"]="flood_fill fprime ft_itoa ft_split rev_wstr rostring ft_list_foreach sort_int_tab sort_list ft_list_remove_if"
    level_order=("level0" "level1" "level2" "level3")
elif [[ "$rank" == "rank03" ]]; then
    level_exercises["level1"]="broken_gnl filter scanf"
    level_exercises["level2"]="n_queens permutations powerset rip tsp"
    level_order=("level1" "level2")
elif [[ "$rank" == "rank04" ]]; then
    level_exercises["level1"]="ft_popen picoshell sandbox"
    level_exercises["level2"]="argo vbc"
    level_order=("level1" "level2")
else
    echo "Unknown rank: $rank"; exit 1
fi

flat_entries=()
for lvl in "${level_order[@]}"; do
    for ex in ${level_exercises[$lvl]}; do
        flat_entries+=("$lvl:$ex")
    done
done
total=${#flat_entries[@]}

draw_picker() {
    clear
    printf "${CYAN}╔═══════════════════════════════════════════════════════════╗${RESET}\n"
    printf "${BLUE}║${GREEN}         🎯 CUSTOM MODE — Cross-Level Picker [${rank}]     ${BLUE}║${RESET}\n"
    printf "${CYAN}╚═══════════════════════════════════════════════════════════╝${RESET}\n"

    current_level=""
    for idx in "${!flat_entries[@]}"; do
        lvl="${flat_entries[$idx]%%:*}"
        ex="${flat_entries[$idx]##*:}"
        num=$((idx + 1))
        if [[ "$lvl" != "$current_level" ]]; then
            echo ""
            printf "  ${CYAN}── %s ─────────────────────────────────${RESET}\n" "$lvl"
            current_level="$lvl"
        fi
        printf "  ${YELLOW}${BOLD}%3d.${RESET}  %s\n" "$num" "$ex"
    done

    echo ""
    printf "${CYAN}─────────────────────────────────────────────────────────────${RESET}\n"
    echo "  Enter numbers separated by spaces."
    echo "  Example: ${GREEN}1 3 15 22${RESET}  or  ${GREEN}all${RESET} for everything."
    echo "  Type ${RED}back${RESET} to cancel."
    printf "${CYAN}─────────────────────────────────────────────────────────────${RESET}\n"
    echo ""
    printf "${GREEN}${BOLD}Your selection: ${RESET}"
}

draw_picker
read -r selection

[[ "$selection" == "back" ]] && { bash rank02_menu.sh; exit; }

chosen_entries=()
if [[ "$selection" == "all" ]]; then
    chosen_entries=("${flat_entries[@]}")
else
    for token in $selection; do
        if [[ "$token" =~ ^[0-9]+$ ]]; then
            idx=$((token - 1))
            if [[ $idx -ge 0 && $idx -lt $total ]]; then
                chosen_entries+=("${flat_entries[$idx]}")
            else
                echo "  ${RED}Out of range: $token${RESET}"
            fi
        fi
    done
fi

# Deduplicate while preserving order
declare -A seen
deduped=()
for entry in "${chosen_entries[@]}"; do
    if [[ -z "${seen[$entry]:-}" ]]; then
        seen["$entry"]=1
        deduped+=("$entry")
    fi
done
chosen_entries=("${deduped[@]}")

if [[ ${#chosen_entries[@]} -eq 0 ]]; then
    echo "  ${RED}Nothing valid selected.${RESET}"
    sleep 1.5
    bash custom_picker.sh "$rank"
    exit
fi

# ── Confirm + order mode ──────────────────────────────────────────────────────
clear
printf "${CYAN}╔═══════════════════════════════════════════════════════════╗${RESET}\n"
printf "${BLUE}║${GREEN}                  ✅ Confirm Selection                  ${BLUE}║${RESET}\n"
printf "${CYAN}╚═══════════════════════════════════════════════════════════╝${RESET}\n"
echo ""
echo "  ${GREEN}Selected (${#chosen_entries[@]} exercises):${RESET}"
for entry in "${chosen_entries[@]}"; do
    lvl="${entry%%:*}"
    ex="${entry##*:}"
    printf "    ${YELLOW}%-10s${RESET}  %s\n" "[$lvl]" "$ex"
done
echo ""
printf "${CYAN}─────────────────────────────────────────────────────────────${RESET}\n"
printf "${YELLOW}${BOLD}%s${RESET}\n" "1. 🔀 Random order"
printf "${YELLOW}${BOLD}%s${RESET}\n" "2. 📋 In order as listed above"
printf "${YELLOW}${BOLD}%s${RESET}\n" "3. Back to picker"
printf "${CYAN}─────────────────────────────────────────────────────────────${RESET}\n"
printf "${GREEN}${BOLD}Order mode (1-3): ${RESET}"
read -r order_opt

case $order_opt in
    1) order="random" ;;
    2) order="ordered" ;;
    3) bash custom_picker.sh "$rank"; exit ;;
    *) order="random" ;;
esac

clear
display_animation
clear

bash custom_runner.sh "$rank" "${chosen_entries[*]}" "$order"
