#!/bin/bash

RENDU_DIR="$(cd "$(dirname "$0")" && pwd)/../../../../rendu/ft_strpbrk"
REF_DIR="$(cd "$(dirname "$0")" && pwd)"

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

pass=0
fail=0

run_test() {
    local desc="$1"
    local expected="$2"
    local got="$3"

    if [ "$got" = "$expected" ]; then
        echo -e "${GREEN}[OK]${RESET} $desc"
        pass=$((pass + 1))
    else
        echo -e "${RED}[KO]${RESET} $desc"
        echo "     expected: '$expected'"
        echo "     got:      '$got'"
        fail=$((fail + 1))
    fi
}

# Compile
cat > /tmp/ft_strpbrk_main.c << 'EOF'
#include <stdio.h>
#include <stddef.h>

char *ft_strpbrk(const char *s1, const char *s2);

int main(int argc, char **argv)
{
    if (argc < 3) { printf("NULL\n"); return 0; }
    char *res = ft_strpbrk(argv[1], argv[2]);
    if (res == NULL)
        printf("NULL\n");
    else
        printf("%s\n", res);
    return 0;
}
EOF

cc -Wall -Wextra -Werror /tmp/ft_strpbrk_main.c "$RENDU_DIR/ft_strpbrk.c" -o /tmp/ft_strpbrk_test 2>/tmp/ft_strpbrk_err
if [ $? -ne 0 ]; then
    echo -e "${RED}Compilation failed:${RESET}"
    cat /tmp/ft_strpbrk_err
    exit 1
fi

T=/tmp/ft_strpbrk_test

run_test "finds first vowel in 'hello world'" "ello world" "$($T "hello world" "aeiou")"
run_test "returns NULL when no match" "NULL" "$($T "hello world" "xyz")"
run_test "empty s2 returns NULL" "NULL" "$($T "hello" "")"
run_test "empty s1 returns NULL" "NULL" "$($T "" "abc")"
run_test "match at first char" "bcde" "$($T "bcde" "b")"
run_test "match at last char" "e" "$($T "bcde" "e")"
run_test "s2 has multiple chars, first match wins" "ello" "$($T "hello" "ole")"

echo ""
if [[ $fail -eq 0 ]]; then
    echo "$(tput setaf 2)$(tput bold)PASSED 🎉$(tput sgr 0)"
else
    echo "$(tput setaf 1)$(tput bold)FAIL$(tput sgr 0)"
    echo "Results: ${pass} passed, ${fail} failed"
fi
exit 1
