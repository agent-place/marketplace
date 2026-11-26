#!/bin/zsh
# 키체인 env/<OLD> 항목의 이름만 env/<NEW> 로 바꾼다. 사용자 이름 · 웹사이트 · 메모 · 암호는 그대로 옮긴다.
# 사용: rename.sh OLD NEW   (env/ 없이 이름만)
# 새 이름이 이미 있으면 멈춘다. 새 항목 저장을 확인한 뒤에만 기존 항목을 지운다
set -u
dir=${0:A:h}
old=${1:?OLD 이름 필요}
new=${2:?NEW 이름 필요}

[[ $new =~ '^[A-Z0-9_]+$' ]] || { print "이름 규칙에 맞지 않음: $new"; exit 1; }
security find-generic-password -s "env/$new" > /dev/null 2>&1 && { print "이미 있음: $new"; exit 1; }
user=$(python3 "$dir/kc.py" get "$old" user) || { print "없음: $old"; exit 1; }
site=$(python3 "$dir/kc.py" get "$old" site)
memo=$(python3 "$dir/kc.py" get "$old" memo)
pw=$(security find-generic-password -a "$user" -s "env/$old" -w 2>/dev/null) || { print "읽기 실패: $old"; exit 1; }

cmd="add-generic-password -a \"$user\" -s \"env/$new\" -l \"env/$new\""
[[ -n $site ]] && cmd+=" -G \"$site\""
[[ -n $memo ]] && cmd+=" -j \"$memo\""
print -r -- "$cmd -w \"$pw\"" | security -i > /dev/null
unset pw cmd

security find-generic-password -a "$user" -s "env/$new" > /dev/null 2>&1 || { print "새 이름 저장 실패, 기존 항목 유지"; exit 1; }
security delete-generic-password -a "$user" -s "env/$old" > /dev/null 2>&1
print "변경됨: env/$old -> env/$new (사용자 이름 $user)"
