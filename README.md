# 🤖 AI Tools Version Checker

Claude Code, Crush (OpenCode), QMD의 최신 버전을 자동으로 체크하는 시스템입니다.

## 기능

- ✅ **자동 체크**: GitHub Actions로 매일 오전 9시 (KST) 자동 실행
- ✅ **Telegram 알림**: 업데이트 필요 시 Telegram으로 알림
- ✅ **로컬 실행**: 수동으로 언제든지 체크 가능
- ✅ **로그 저장**: `~/.claude/version_check.log`에 기록
- ✅ **자동 이슈 생성**: 업데이트 필요 시 GitHub Issue 자동 생성

## 체크하는 도구

| 도구 | GitHub Repo | 설명 |
|------|-------------|------|
| **Claude Code** | [anthropics/claude-code](https://github.com/anthropics/claude-code) | AI 코딩 어시스턴트 |
| **Crush** | [charmbracelet/crush](https://github.com/charmbracelet/crush) | OpenCode (리브랜딩) |
| **QMD** | [tobi/qmd](https://github.com/tobi/qmd) | Markdown 검색 도구 |

## 설정

### 1. GitHub Secrets 설정

GitHub repo의 Settings > Secrets에 추가:

```
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here
```

### 2. 로컬 환경 변수 설정

`~/.zshrc` 또는 `~/.bashrc`에 추가:

```bash
export TELEGRAM_BOT_TOKEN="your_bot_token_here"
export TELEGRAM_CHAT_ID="your_chat_id_here"
```

## 사용법

### 로컬 실행

```bash
# 터미널 출력만
./check_versions.sh stdout

# Telegram + 터미널 + 로그
./check_versions.sh all

# 로그 파일만
./check_versions.sh log

# Telegram만
./check_versions.sh telegram
```

### GitHub Actions 수동 실행

1. GitHub repo의 **Actions** 탭 이동
2. **Check AI Tools Versions** workflow 선택
3. **Run workflow** 버튼 클릭

## 출력 예시

```
========================================
🔍 AI Tools 버전 체크 시작
========================================

[1/3] Claude Code 체크...
  ✅ Claude Code: 1.2.3 (최신)

[2/3] Crush (OpenCode) 체크...
  🔄 Crush: 1.0.0 → 1.1.0 (업데이트 필요)
     업데이트: brew upgrade charmbracelet/tap/crush

[3/3] QMD 체크...
  ✅ QMD: 2.0.0 (최신)

========================================
⚠️  업데이트 필요한 도구가 있습니다!
========================================
```

## Telegram 알림 예시

```
🤖 AI Tools 버전 체크

✅ Claude Code: 1.2.3 (최신)
🔄 Crush: 1.0.0 → 1.1.0
   업데이트: brew upgrade charmbracelet/tap/crush
✅ QMD: 2.0.0 (최신)

⚠️ 업데이트 필요!
```

## 스케줄

- **매일 오전 9시 (KST)** 자동 실행
- **Push 시** 즉시 실행
- **수동 실행** 가능 (workflow_dispatch)

## 로그 파일

위치: `~/.claude/version_check.log`

```
[2026-02-09 09:00:00] 🔍 AI Tools 버전 체크 시작
[2026-02-09 09:00:01] ✅ Claude Code: 1.2.3 (최신)
[2026-02-09 09:00:02] 🔄 Crush: 1.0.0 → 1.1.0 (업데이트 필요)
...
```

## 라이선스

MIT

## 기여

이슈와 PR 환영합니다!
