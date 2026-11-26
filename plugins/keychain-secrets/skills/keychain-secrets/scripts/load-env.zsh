# 키체인 env/<NAME> 항목을 모두 환경 변수로 export 한다. ~/.zshrc 에서 source 한다.
#   <NAME>_USER = 사용자 이름, <NAME>_PW = 암호, <NAME>_URL = 웹사이트, <NAME>_MEMO = 메모 (웹사이트 · 메모는 있을 때만)
# 항목을 키체인에 추가 · 삭제하면 새 셸부터 반영된다. 읽지 못한 항목은 건너뛴다
() {
  local dir=${${(%):-%x}:A:h}
  local name user site memo pw
  python3 "$dir/kc.py" list 2>/dev/null | while IFS=$'\t' read -r name user site memo; do
    [[ $name =~ '^[A-Z0-9_]+$' ]] || continue
    pw=$(security find-generic-password -a "$user" -s "env/$name" -w 2>/dev/null) || continue
    export "${name}_USER=$user" "${name}_PW=$pw"
    [[ -n $site ]] && export "${name}_URL=$site"
    [[ -n $memo ]] && export "${name}_MEMO=$memo"
  done
  unset pw
}
