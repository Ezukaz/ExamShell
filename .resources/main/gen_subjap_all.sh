#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

total=0
created=0
skipped=0

declare -a created_paths

while IFS= read -r sub; do
  total=$((total + 1))
  dir=$(dirname "$sub")
  jp="$dir/subjap.txt"

  if [ -f "$jp" ]; then
    skipped=$((skipped + 1))
    continue
  fi

  {
    printf '【日本語版 (自動生成)】\n'
    sed -e 's/^Assignment name[[:space:]]*:/課題名           :/' \
        -e 's/^Expected files[[:space:]]*:/提出ファイル      :/' \
        -e 's/^Allowed functions[[:space:]]*:/使用可能関数      :/' \
        -e 's/^Examples:/例:/' \
        -e 's/^Example:/例:/' \
        -e 's/Write a program/プログラムを書いてください/g' \
        -e 's/Write a function/関数を書いてください/g' \
        -e 's/Your function must be declared as follows:/関数宣言は次の通りです:/g' \
        -e 's/If the number of arguments is not/引数の数が正しくない場合は/g' \
        -e 's/followed by a newline/最後に改行を付けて/g' \
        "$sub"
  } > "$jp"

  created=$((created + 1))
  created_paths+=("$jp")
done < <(find .resources -type f -name sub.txt | sort)

missing=0
while IFS= read -r sub; do
  jp="$(dirname "$sub")/subjap.txt"
  if [ ! -f "$jp" ]; then
    missing=$((missing + 1))
  fi
done < <(find .resources -type f -name sub.txt | sort)

echo "TOTAL_SUB:$total"
echo "CREATED_SUBJAP:$created"
echo "SKIPPED_EXISTING:$skipped"
echo "MISSING_SUBJAP:$missing"
echo "CREATED_PATHS_FIRST_10:"

limit=10
idx=0
for p in "${created_paths[@]}"; do
  echo "$p"
  idx=$((idx + 1))
  if [ "$idx" -ge "$limit" ]; then
    break
  fi
done
