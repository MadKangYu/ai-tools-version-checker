# 🤖 AI Tools Auto Version Checker & Updater

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Shell Script](https://img.shields.io/badge/Shell_Script-4EAA25?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

Claude Code, OpenCode, Oh-My-OpenCode, QMD의 최신 버전을 **자동으로 체크하고 업데이트**하는 전문가급 시스템입니다.

## ✨ 주요 기능

### 🔄 자동 업데이트
- **완전 자동화**: 매일 오전 9시 자동 실행 (launchd)
- **스마트 업데이트**: 버전 비교 후 자동 업데이트
- **롤백 대비**: 업데이트 전 자동 백업
- **안전성**: 실패 시 이전 버전으로 복구 가능

### 📊 버전 체크
- **4개 도구 추적**: Claude Code, OpenCode, Oh-My-OpenCode, QMD
- **GitHub 실시간 조회**: 최신 릴리즈 자동 확인
- **상세 비교**: 현재 버전 vs 최신 버전

### 🔔 알림 시스템
- **Telegram 알림**: 업데이트 완료 시 자동 알림
- **상세 리포트**: 업데이트 내역, 소요 시간, 현재 버전
- **HTML 포맷**: 읽기 쉬운 구조화된 메시지

### 📝 로깅 시스템
- **날짜별 로그**: `~/.claude/auto_update_YYYYMMDD.log`
- **타임스탬프**: 시작/종료 시간, 소요 시간 기록
- **자동 정리**: 30일 이상 된 로그 자동 삭제
- **최신 로그 링크**: `~/.claude/auto_update.log` 심볼릭 링크

### 💾 백업 시스템
- **버전별 백업**: `~/.claude/backups/[tool]_[version]_[date].txt`
- **업데이트 전 자동 백업**: 실패 시 복구 가능
- **백업 히스토리**: 모든 업데이트 기록 보존

## 🛠️ 체크하는 도구

| 도구 | GitHub Repo | 설명 | 업데이트 방법 |
|------|-------------|------|--------------|
| **Claude Code** | [anthropics/claude-code](https://github.com/anthropics/claude-code) | Terminal에서 실행되는 agentic 코딩 도구 | `brew upgrade --cask claude-code` |
| **OpenCode** | [opencode-ai/opencode](https://github.com/opencode-ai/opencode) | 오픈소스 AI 코딩 에이전트 (95K+ ⭐) | `brew upgrade opencode` |
| **Oh-My-OpenCode** | [code-yeongyu/oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode) | OpenCode용 멀티모델 에이전트 하네스 | `oh-my-opencode update` |
| **QMD** | [tobi/qmd](https://github.com/tobi/qmd) | Markdown 문서 검색 도구 | `bun install -g https://github.com/tobi/qmd` |

## 📦 설치

### 1. 저장소 클론

```bash
git clone https://github.com/MadKangYu/ai-tools-version-checker.git
cd ai-tools-version-checker
chmod +x check_versions.sh auto_update.sh
```

### 2. 환경 변수 설정

`~/.zshrc` 또는 `~/.bashrc`에 추가:

```bash
export TELEGRAM_BOT_TOKEN="your_bot_token_here"
export TELEGRAM_CHAT_ID="your_chat_id_here"
```

### 3. launchd 설정 (macOS 자동 실행)

#### 템플릿 복사 및 수정

```bash
# 템플릿을 LaunchAgents로 복사
cp ai.tools.auto-update.plist.template ~/Library/LaunchAgents/ai.tools.auto-update.plist

# 경로 수정 (필요시)
nano ~/Library/LaunchAgents/ai.tools.auto-update.plist
```

#### launchd 등록

```bash
# 등록
launchctl load ~/Library/LaunchAgents/ai.tools.auto-update.plist

# 상태 확인
launchctl list | grep ai.tools

# 수동 실행 (테스트)
launchctl start ai.tools.auto-update
```

#### launchd 관리

```bash
# 중지
launchctl unload ~/Library/LaunchAgents/ai.tools.auto-update.plist

# 재시작
launchctl unload ~/Library/LaunchAgents/ai.tools.auto-update.plist
launchctl load ~/Library/LaunchAgents/ai.tools.auto-update.plist

# 로그 확인
tail -f ~/.claude/auto_update_stdout.log
tail -f ~/.claude/auto_update_stderr.log
```

## 🚀 사용법

### 버전 체크만 (업데이트 안함)

```bash
# 터미널 출력
./check_versions.sh stdout

# Telegram + 터미널 + 로그
./check_versions.sh all

# 로그 파일만
./check_versions.sh log

# Telegram만
./check_versions.sh telegram
```

### 자동 업데이트 실행

```bash
# 버전 체크 → 업데이트 → Telegram 알림
./auto_update.sh
```

**자동 업데이트가 수행하는 작업:**
1. 현재 설치된 버전 확인
2. 버전 백업 (`~/.claude/backups/`)
3. Homebrew/Bun으로 최신 버전 설치
4. 업데이트 성공/실패 확인
5. Telegram으로 결과 알림
6. 날짜별 로그 저장 (`~/.claude/auto_update_YYYYMMDD.log`)
7. 30일 이상 된 로그 자동 삭제

## 📊 출력 예시

### 터미널 출력

```
========================================
🤖 AI Tools 자동 업데이트 시작
📅 실행 시간: 2026-02-09 09:00:00
========================================

[Claude Code 업데이트]
  📦 백업 완료: ~/.claude/backups/claude_1.2.3_20260209.txt
  🔄 Homebrew로 업데이트 중...
  ✅ 업데이트 완료: 1.2.3 → 1.2.4

[OpenCode 업데이트]
  📦 백업 완료: ~/.claude/backups/opencode_2.1.0_20260209.txt
  🔄 Homebrew로 업데이트 중...
  ℹ️  이미 최신 버전: 2.1.0

[Oh-My-OpenCode 업데이트]
  📦 백업 완료: ~/.claude/backups/oh-my-opencode_3.4.0_20260209.txt
  🔄 업데이트 중...
  ℹ️  이미 최신 버전: 3.4.0

[QMD 업데이트]
  📦 백업 완료: ~/.claude/backups/qmd_1.0.5_20260209.txt
  🔄 Bun으로 업데이트 중...
  ✅ 업데이트 완료: 1.0.5 → 1.0.6

========================================
📊 업데이트 결과
========================================
✅ 업데이트 완료 (2개):
  - Claude Code
  - QMD

현재 버전:
  Claude Code: 1.2.4
  OpenCode: 2.1.0
  Oh-My-OpenCode: 3.4.0
  QMD: 1.0.6
========================================

⏱️  실행 완료 시간: 2026-02-09 09:05:23
⏱️  소요 시간: 5분 23초

✅ 자동 업데이트 완료
📝 로그: ~/.claude/auto_update_20260209.log
💾 백업: ~/.claude/backups
```

### Telegram 알림

```
🤖 AI Tools 자동 업데이트
📅 실행 시간: 2026-02-09 09:00:00

✅ Claude Code 업데이트 완료
✅ QMD 업데이트 완료

현재 버전:
  Claude: 1.2.4
  OpenCode: 2.1.0
  Oh-My-OpenCode: 3.4.0
  QMD: 1.0.6

⏱️ 완료 시간: 2026-02-09 09:05:23
⏱️ 소요 시간: 5분 23초
```

## 📁 디렉토리 구조

```
~/.claude/
├── auto_update_20260209.log      # 날짜별 로그
├── auto_update.log                # 최신 로그 (심볼릭 링크)
├── auto_update_stdout.log         # launchd 표준 출력
├── auto_update_stderr.log         # launchd 표준 에러
└── backups/
    ├── claude_1.2.3_20260209.txt
    ├── opencode_2.1.0_20260209.txt
    ├── oh-my-opencode_3.4.0_20260209.txt
    └── qmd_1.0.5_20260209.txt
```

## 🔧 설정

### Telegram Bot 설정

1. [@BotFather](https://t.me/BotFather)에게 `/newbot` 명령
2. Bot 이름과 username 설정
3. Bot Token 받기 (`TELEGRAM_BOT_TOKEN`)
4. [@userinfobot](https://t.me/userinfobot)에게 메시지 보내서 Chat ID 확인 (`TELEGRAM_CHAT_ID`)

### launchd 실행 시간 변경

`~/Library/LaunchAgents/ai.tools.auto-update.plist` 수정:

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>9</integer>        <!-- 원하는 시간 (0-23) -->
    <key>Minute</key>
    <integer>0</integer>        <!-- 원하는 분 (0-59) -->
</dict>
```

수정 후 재시작:
```bash
launchctl unload ~/Library/LaunchAgents/ai.tools.auto-update.plist
launchctl load ~/Library/LaunchAgents/ai.tools.auto-update.plist
```

## 🐛 트러블슈팅

### Claude Code가 Homebrew에 없을 때

Native 설치 사용 중일 수 있습니다:

```bash
# 수동 업데이트
curl -fsSL https://claude.ai/install.sh | bash
```

### Oh-My-OpenCode 업데이트 실패

`oh-my-opencode update` 명령이 없을 수 있습니다:

```bash
# GitHub에서 최신 릴리즈 확인 후 수동 설치
# https://github.com/code-yeongyu/oh-my-opencode
```

### launchd가 실행되지 않을 때

```bash
# 로그 확인
tail -f ~/.claude/auto_update_stderr.log

# 권한 확인
ls -l ~/Library/LaunchAgents/ai.tools.auto-update.plist

# PATH 환경 변수 확인
launchctl getenv PATH
```

### 로그 파일이 너무 많을 때

수동 정리:

```bash
# 30일 이상 된 로그 삭제
find ~/.claude -name "auto_update_*.log" -type f -mtime +30 -delete
```

## 📈 로그 분석

### 최신 로그 확인

```bash
# 최신 로그 전체
cat ~/.claude/auto_update.log

# 실시간 모니터링
tail -f ~/.claude/auto_update.log

# 에러만 필터링
grep "ERROR\|⚠️" ~/.claude/auto_update.log
```

### 특정 날짜 로그 확인

```bash
# 2026년 2월 9일 로그
cat ~/.claude/auto_update_20260209.log
```

## 🔐 보안

- Telegram Bot Token은 환경 변수로 관리
- `.env` 파일 사용 시 `.gitignore`에 추가
- GitHub Secrets에 저장 (CI/CD 사용 시)

## 📝 로그 보존 정책

- **날짜별 로그**: `~/.claude/auto_update_YYYYMMDD.log`
- **보존 기간**: 30일
- **자동 정리**: `auto_update.sh` 실행 시 자동 삭제
- **백업**: 수동 백업 필요 시 `~/.claude/backups/` 참조

## 🤝 기여

이슈와 PR 환영합니다!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능합니다.

## 🙏 감사

- [Claude Code](https://github.com/anthropics/claude-code) by Anthropic
- [OpenCode](https://github.com/anomalyco/opencode) by Anomaly
- [Oh-My-OpenCode](https://github.com/code-yeongyu/oh-my-opencode) by code-yeongyu
- [QMD](https://github.com/tobi/qmd) by tobi

---

**Made with ❤️ by [@MadKangYu](https://github.com/MadKangYu)**
