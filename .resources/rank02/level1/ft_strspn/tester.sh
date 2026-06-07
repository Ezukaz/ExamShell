#!/bin/bash

RENDU_DIR="$(cd "$(dirname "$0")" && pwd)/../../../../rendu/ft_strspn"
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
cat > /tmp/ft_strspn_main.c << 'EOF'
#include <stdio.h>
#include <stddef.h>

size_t ft_strspn(const char *s, const char *accept);

int main(int argc, char **argv)
{
    if (argc < 3) { printf("0\n"); return 0; }
    printf("%zu\n", ft_strspn(argv[1], argv[2]));
    return 0;
}
EOF

cc -Wall -Wextra -Werror /tmp/ft_strspn_main.c "$RENDU_DIR/ft_strspn.c" -o /tmp/ft_strspn_test 2>/tmp/ft_strspn_err
if [ $? -ne 0 ]; then
    echo -e "${RED}Compilation failed:${RESET}"
    cat /tmp/ft_strspn_err
    exit 1
fi

T=/tmp/ft_strspn_test

run_test "all chars match 'hel' in 'hello'" "4"    "$($T "hello" "hel")"
run_test "no match returns 0" "0"               "$($T "hello" "xyz")"
run_test "empty accept returns 0" "0"           "$($T "hello" "")"
run_test "empty s returns 0" "0"               "$($T "" "abc")"
run_test "aabbcc with accept ab -> 4" "4"       "$($T "aabbcc" "ab")"
run_test "full string match" "5"               "$($T "hello" "helo")"
run_test "single char match" "1"               "$($T "abc" "a")"
run_test "accept longer than s" "3"            "$($T "abc" "abcdefg")"

echo ""
if [[ $fail -eq 0 ]]; then
    echo "$(tput setaf 2)$(tput bold)PASSED 🎉$(tput sgr 0)"
else
    echo "$(tput setaf 1)$(tput bold)FAIL$(tput sgr 0)"
    echo "Results: ${pass} passed, ${fail} failed"
fi
exit 1
