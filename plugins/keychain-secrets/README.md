# keychain-secrets

macOS 로그인 키체인에 비밀 값을 `env/<NAME>` 규칙으로 저장하고, 환경 변수 `<NAME>_USER` · `<NAME>_PW` · `<NAME>_URL` · `<NAME>_MEMO` 로 쓰는 Claude Code 스킬이다.
저장 · 조회 · 이름 변경 · 삭제는 대화로 요청한다.

## 요구 사항

- macOS (`security` · `osascript` 사용)
- zsh, python3

## 설치

```
/plugin marketplace add agent-place/marketplace
/plugin install keychain-secrets@agent-place
```

플러그인 없이 쓰려면 `skills/keychain-secrets` 폴더를 `~/.claude/skills/` 에 복사한다.

## 환경 변수 자동 등록

`~/.zshrc` 에 아래 한 줄을 추가하면 셸이 시작될 때 `env/` 항목이 모두 환경 변수로 등록된다.
플러그인 설치 경로는 버전마다 달라지므로, 가장 높은 버전(없으면 수동 설치 경로)을 찾아 불러온다.

```zsh
() { local f=( ~/.claude/plugins/cache/*/keychain-secrets/*/skills/keychain-secrets/scripts/load-env.zsh(NnOn) ~/.claude/skills/keychain-secrets/scripts/load-env.zsh(N) ); (( $#f )) && source $f[1] }
```

이 줄이 없어도 스킬은 동작한다. 그 경우 명령마다 `with-env.sh` 로 값을 넣는다.

## 항목 구성

키체인 일반 암호 항목 하나에 아래 칸을 담는다.

| 칸 | 키체인 속성 | 환경 변수 |
|---|---|---|
| 제목 `env/<NAME>` | 서비스 이름 · 레이블 | - |
| 사용자 이름 | 계정 | `<NAME>_USER` |
| 암호 | 암호 | `<NAME>_PW` |
| 웹사이트 | 일반 속성 (`-G`) | `<NAME>_URL` |
| 메모 | 설명 (`-j`) | `<NAME>_MEMO` |

- `NAME` 은 영문 대문자 · 숫자 · `_` 만 쓴다. 예: `env/JIRA` → `JIRA_USER` · `JIRA_PW`
- 웹사이트는 그 값을 보낼 곳이다. 스킬은 이 호스트로만 값을 보낸다
- 메모에는 사용 조건을 적는다. 형식: `<용도>. 인증: <방식>. 범위: <권한>. 주의: <제약>. 만료: <YYYY-MM-DD>`

## 사용 예

| 요청 | 동작 |
|---|---|
| "Jira 토큰 저장해줘" | 입력창(제목 · 사용자 이름 · 암호 · 웹사이트 · 메모)을 띄워 저장 |
| "키체인 목록 보여줘" | 이름 · 사용자 이름 · 웹사이트 · 메모 출력 (암호 제외) |
| "JIRA 를 JIRA_CLOUD 로 이름 바꿔줘" | 값과 다른 칸을 유지한 채 이름만 변경 |
| "JIRA 지워줘" | 확인 후 삭제 |
| "Jira 에서 내 이슈 조회해줘" | 메모를 읽고 `JIRA_USER` · `JIRA_PW` 로 요청 |

## 비밀 값 취급

- 비밀 값은 대화로 받지 않고 입력창(`NSSecureTextField`)으로 받는다
- 키체인에는 `security -i` 의 표준 입력으로 넘겨 프로세스 목록 · 셸 기록에 남기지 않는다
- 값은 출력 · 파일 저장하지 않는다. 확인은 길이나 종료 코드로 한다
- 메모의 제약(읽기 전용, 만료일 등)과 요청이 어긋나면 실행하지 않는다

## 한계

- 로그인 키체인은 macOS 로그인과 함께 잠금이 풀린다. 풀린 동안 같은 사용자로 실행한 `security` 는 허용된 항목을 읽을 수 있다
- 환경 변수로 등록한 값은 그 셸에서 실행한 모든 프로세스가 읽을 수 있다. 토큰 권한 범위를 필요한 만큼으로 제한한다
- 키체인 접근 앱에서 직접 만든 항목은 처음 읽을 때 접근 허용 창이 한 번 뜬다
- 입력창 · `security -i` 명령 형식상 `"` · `\` 가 들어간 값은 저장하지 않는다
