# ai-agentplaces marketplace

Claude Code 용 범용 스킬 모음이다.
스킬마다 플러그인 하나로 등록되어 있어 필요한 것만 골라 설치한다.

## 설치

Claude Code 에서 마켓플레이스를 한 번 추가한 뒤, 원하는 플러그인을 설치한다.

```
/plugin marketplace add ai-agentplaces/marketplace
/plugin install keychain-secrets@ai-agentplaces
```

업데이트는 `/plugin` 메뉴의 Marketplaces 에서 받는다.

## 플러그인 목록

| 플러그인 | 설명 | 환경 |
|---|---|---|
| [keychain-secrets](plugins/keychain-secrets/README.md) | macOS 키체인의 `env/<NAME>` 항목을 환경 변수로 쓰는 비밀 값 관리 | macOS |

## 구조

```
.claude-plugin/marketplace.json     플러그인 목록
plugins/<플러그인>/
├── .claude-plugin/plugin.json
├── README.md
└── skills/<스킬>/SKILL.md, scripts/
```

새 플러그인은 `plugins/` 에 폴더를 추가하고 `marketplace.json` 의 `plugins` 에 한 줄을 등록한다.
