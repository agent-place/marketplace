#!/bin/zsh
# 입력창(prompt.js)을 띄워 키체인 env/<NAME> 항목을 저장한다. 같은 이름이 있으면 그 값으로 창을 채우고 덮어쓴다.
# 사용: save.sh [env/NAME] [사용자 이름] [웹사이트] [메모]   (인자가 비면 기존 항목 값으로 채움)
# 출력: 저장한 제목 · 사용자 이름 · 웹사이트 · 메모와 암호 길이. 암호는 출력하지 않는다
set -u
dir=${0:A:h}
title=${1:-env/}
name=${title#env/}

# 기존 항목이 있으면 비어 있는 제안값을 그 속성으로 채움
user=${2:-}
site=${3:-}
memo=${4:-}
if [[ -n $name ]] && security find-generic-password -s "env/$name" > /dev/null 2>&1; then
  [[ -z $user ]] && user=$(python3 "$dir/kc.py" get "$name" user)
  [[ -z $site ]] && site=$(python3 "$dir/kc.py" get "$name" site)
  [[ -z $memo ]] && memo=$(python3 "$dir/kc.py" get "$name" memo)
fi

out=$(osascript -l JavaScript "$dir/prompt.js" "$title" "$user" "$site" "$memo" 2>/dev/null) || { print "취소됨"; exit 1; }
lines=("${(@f)out}")
unset out
title=${lines[1]}
user=${lines[2]}
site=${lines[3]}
memo=${lines[4]}
pw=${lines[5]:-}
unset lines

if [[ ! $title =~ '^env/[A-Z0-9_]+$' ]]; then
  unset pw
  print "제목 규칙에 맞지 않음: $title (env/ 뒤 영문 대문자 · 숫자 · _)"
  exit 1
fi
if [[ -z $user || -z $pw ]]; then
  unset pw
  print "사용자 이름 · 암호가 비어 있어 저장하지 않음"
  exit 1
fi
# security -i 명령 줄은 큰따옴표로 감싸므로 " \ 가 있으면 깨짐
if [[ "$title$user$site$memo$pw" == *[\"\\]* ]]; then
  unset pw
  print "\" 또는 \\ 가 들어 있어 저장하지 않음"
  exit 1
fi

old_user=$(python3 "$dir/kc.py" get "${title#env/}" user 2>/dev/null)
cmd="add-generic-password -U -a \"$user\" -s \"$title\" -l \"$title\""
[[ -n $site ]] && cmd+=" -G \"$site\""
[[ -n $memo ]] && cmd+=" -j \"$memo\""
print -r -- "$cmd -w \"$pw\"" | security -i > /dev/null
unset pw cmd

if ! security find-generic-password -a "$user" -s "$title" > /dev/null 2>&1; then
  print "저장 실패"
  exit 1
fi
# 사용자 이름을 바꿨으면 예전 항목을 지워 이름당 항목 하나를 유지
if [[ -n $old_user && $old_user != "$user" ]]; then
  security delete-generic-password -a "$old_user" -s "$title" > /dev/null 2>&1
fi
print "제목: $title"
print "사용자 이름: $user"
print "웹사이트: $site"
print "메모: $memo"
print "암호 길이: $(security find-generic-password -a "$user" -s "$title" -w | tr -d '\n' | wc -c | tr -d ' ')"
