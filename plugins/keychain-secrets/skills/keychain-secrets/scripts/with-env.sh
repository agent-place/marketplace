#!/bin/zsh
# 키체인 env/<NAME> 항목을 모두 환경 변수(<NAME>_USER · <NAME>_PW · <NAME>_URL · <NAME>_MEMO)로 넣고 명령 하나를 실행한다.
# ~/.zshrc 의 load-env.zsh 가 적용되지 않은 셸(그 전에 시작한 세션 등)에서 쓴다. 변수는 그 명령에만 있다.
# 사용: with-env.sh 명령 [인자...]
#   변수를 인자 안에서 쓰려면 sh -c 로 감싼다 (바깥 셸이 먼저 풀지 않게 작은따옴표):
#   with-env.sh sh -c 'curl -u "$JIRA_USER:$JIRA_PW" "$JIRA_URL/rest/api/3/myself"'
source "${0:A:h}/load-env.zsh"
exec "$@"
