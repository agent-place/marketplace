#!/usr/bin/env python3
"""키체인 env/<NAME> 항목의 속성을 읽는다. 암호(값)는 다루지 않는다.

사용:
  kc.py list               이름 · 사용자 이름 · 웹사이트 · 메모를 탭으로 구분해 출력
  kc.py get NAME FIELD     한 항목의 속성 하나 출력 (FIELD: user | site | memo). 항목이 없으면 종료 코드 44

security 는 UTF-8(한글 등) 속성을 0x<hex> "..." 형식으로 출력하므로 hex 를 풀어 읽는다.
"""
import re
import subprocess
import sys

PREFIX = "env/"
# security 출력의 속성 키: acct=계정, svce=서비스, icmt=설명(메모), gena=일반 속성(웹사이트)
FIELDS = {"user": "acct", "site": "gena", "memo": "icmt"}
ATTR = re.compile(r'^\s*"(\w{4})"<blob>=(?:0x([0-9A-Fa-f]+)\s.*|"(.*)"|<NULL>)\s*$')


def parse(text):
    """security 출력을 항목별 속성 사전 목록으로 나눈다."""
    items, cur = [], None
    for line in text.splitlines():
        if line.startswith("keychain:"):
            cur = {}
            items.append(cur)
            continue
        m = ATTR.match(line)
        if m and cur is not None:
            key, hexval, plain = m.groups()
            if hexval is not None:
                cur[key] = bytes.fromhex(hexval).decode("utf-8", "replace")
            elif plain is not None:
                cur[key] = plain
            else:
                cur[key] = ""
    return items


def main(argv):
    if len(argv) >= 2 and argv[1] == "list":
        dump = subprocess.run(["security", "dump-keychain"], capture_output=True, text=True).stdout
        rows = set()
        for it in parse(dump):
            svc = it.get("svce", "")
            if svc.startswith(PREFIX):
                rows.add((svc[len(PREFIX):], it.get("acct", ""), it.get("gena", ""), it.get("icmt", "")))
        for row in sorted(rows):
            print("\t".join(row))
        return 0
    if len(argv) == 4 and argv[1] == "get" and argv[3] in FIELDS:
        res = subprocess.run(["security", "find-generic-password", "-s", PREFIX + argv[2]],
                             capture_output=True, text=True)
        if res.returncode != 0:
            return 44
        items = [it for it in parse(res.stdout) if it]
        print(items[0].get(FIELDS[argv[3]], "") if items else "")
        return 0
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
