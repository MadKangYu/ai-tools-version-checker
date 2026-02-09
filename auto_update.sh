#!/bin/bash

# AI Tools 자동 업데이트 스크립트
# 매일 자동으로 최신 버전으로 업데이트

set -euo pipefail

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 로그 파일 (날짜별)
LOG_DATE=$(date '+%Y%m%d')
LOG_FILE="$HOME/.claude/auto_update_${LOG_DATE}.log"
LOG_LATEST="$HOME/.claude/auto_update.log"  # 최신 로그 심볼릭 링크
BACKUP_DIR="$HOME/.claude/backups"
mkdir -p "$HOME/.claude" "$BACKUP_DIR"

# Telegram 설정
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "$message"
    echo "[$timestamp] $message" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
}

send_telegram() {
    local message="$1"
    if [[ -n "$TELEGRAM_BOT_TOKEN" ]] && [[ -n "$TELEGRAM_CHAT_ID" ]]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$message" \
            -d parse_mode="HTML" > /dev/null
    fi
}

get_version() {
    local tool="$1"
    case "$tool" in
        "claude") claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "not_installed" ;;
        "opencode") opencode --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "not_installed" ;;
        "oh-my-opencode") oh-my-opencode --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "not_installed" ;;
        "qmd") qmd --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "not_installed" ;;
    esac
}

backup_version() {
    local tool="$1"
    local version="$2"
    local backup_file="$BACKUP_DIR/${tool}_${version}_$(date +%Y%m%d).txt"
    echo "Backed up: $tool v$version at $(date)" > "$backup_file"
    log "  📦 백업 완료: $backup_file"
}

update_claude() {
    log "${BLUE}[Claude Code 업데이트]${NC}"
    local old_version=$(get_version "claude")

    if [[ "$old_version" != "not_installed" ]]; then
        backup_version "claude" "$old_version"
    fi

    # Homebrew로 업데이트
    if brew list --cask | grep -q "claude-code"; then
        log "  🔄 Homebrew로 업데이트 중..."
        brew upgrade --cask claude-code 2>&1 | tee -a "$LOG_FILE"
    else
        log "  ⚠️  Homebrew에 설치되지 않음. Native 설치 감지됨."
        log "  💡 수동 업데이트: curl -fsSL https://claude.ai/install.sh | bash"
    fi

    local new_version=$(get_version "claude")

    if [[ "$old_version" != "$new_version" ]]; then
        log "  ${GREEN}✅ 업데이트 완료: $old_version → $new_version${NC}"
        return 0
    else
        log "  ${YELLOW}ℹ️  이미 최신 버전: $old_version${NC}"
        return 1
    fi
}

update_opencode() {
    log "${BLUE}[OpenCode 업데이트]${NC}"
    local old_version=$(get_version "opencode")

    if [[ "$old_version" != "not_installed" ]]; then
        backup_version "opencode" "$old_version"
    fi

    log "  🔄 Homebrew로 업데이트 중..."
    brew upgrade opencode 2>&1 | tee -a "$LOG_FILE"

    local new_version=$(get_version "opencode")

    if [[ "$old_version" != "$new_version" ]]; then
        log "  ${GREEN}✅ 업데이트 완료: $old_version → $new_version${NC}"
        return 0
    else
        log "  ${YELLOW}ℹ️  이미 최신 버전: $old_version${NC}"
        return 1
    fi
}

update_oh_my_opencode() {
    log "${BLUE}[Oh-My-OpenCode 업데이트]${NC}"
    local old_version=$(get_version "oh-my-opencode")

    if [[ "$old_version" != "not_installed" ]]; then
        backup_version "oh-my-opencode" "$old_version"
    fi

    log "  🔄 업데이트 중..."
    # Oh-My-OpenCode 설치/업데이트 방법에 따라 수정 필요
    if command -v oh-my-opencode &> /dev/null; then
        oh-my-opencode update 2>&1 | tee -a "$LOG_FILE" || {
            log "  💡 수동 업데이트: https://github.com/code-yeongyu/oh-my-opencode"
        }
    else
        log "  ⚠️  미설치 또는 업데이트 명령어 없음"
        return 1
    fi

    local new_version=$(get_version "oh-my-opencode")

    if [[ "$old_version" != "$new_version" ]]; then
        log "  ${GREEN}✅ 업데이트 완료: $old_version → $new_version${NC}"
        return 0
    else
        log "  ${YELLOW}ℹ️  이미 최신 버전: $old_version${NC}"
        return 1
    fi
}

update_qmd() {
    log "${BLUE}[QMD 업데이트]${NC}"
    local old_version=$(get_version "qmd")

    if [[ "$old_version" != "not_installed" ]]; then
        backup_version "qmd" "$old_version"
    fi

    log "  🔄 Bun으로 업데이트 중..."
    bun install -g https://github.com/tobi/qmd 2>&1 | tee -a "$LOG_FILE"

    local new_version=$(get_version "qmd")

    if [[ "$old_version" != "$new_version" ]]; then
        log "  ${GREEN}✅ 업데이트 완료: $old_version → $new_version${NC}"
        return 0
    else
        log "  ${YELLOW}ℹ️  이미 최신 버전: $old_version${NC}"
        return 1
    fi
}

# 메인
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
START_TIMESTAMP=$(date +%s)

log ""
log "${BLUE}========================================${NC}"
log "${BLUE}🤖 AI Tools 자동 업데이트 시작${NC}"
log "${BLUE}📅 실행 시간: $START_TIME${NC}"
log "${BLUE}========================================${NC}"
log ""

telegram_message="🤖 <b>AI Tools 자동 업데이트</b>\n"
telegram_message+="📅 <b>실행 시간</b>: $START_TIME\n\n"
updated_tools=()
failed_tools=()

# 1. Claude Code
if update_claude; then
    updated_tools+=("Claude Code")
else
    if [[ $(get_version "claude") == "not_installed" ]]; then
        failed_tools+=("Claude Code (미설치)")
    fi
fi
log ""

# 2. OpenCode
if update_opencode; then
    updated_tools+=("OpenCode")
else
    if [[ $(get_version "opencode") == "not_installed" ]]; then
        failed_tools+=("OpenCode (미설치)")
    fi
fi
log ""

# 3. Oh-My-OpenCode
if update_oh_my_opencode; then
    updated_tools+=("Oh-My-OpenCode")
else
    if [[ $(get_version "oh-my-opencode") == "not_installed" ]]; then
        failed_tools+=("Oh-My-OpenCode (미설치)")
    fi
fi
log ""

# 4. QMD
if update_qmd; then
    updated_tools+=("QMD")
else
    if [[ $(get_version "qmd") == "not_installed" ]]; then
        failed_tools+=("QMD (미설치)")
    fi
fi
log ""

# 결과 요약
log "${BLUE}========================================${NC}"
log "${BLUE}📊 업데이트 결과${NC}"
log "${BLUE}========================================${NC}"

if [[ ${#updated_tools[@]} -gt 0 ]]; then
    log "${GREEN}✅ 업데이트 완료 (${#updated_tools[@]}개):${NC}"
    for tool in "${updated_tools[@]}"; do
        log "  - $tool"
        telegram_message+="✅ $tool 업데이트 완료\n"
    done
else
    log "${YELLOW}ℹ️  업데이트된 도구 없음 (모두 최신)${NC}"
    telegram_message+="ℹ️ 모든 도구가 이미 최신 버전입니다.\n"
fi

if [[ ${#failed_tools[@]} -gt 0 ]]; then
    log "${RED}⚠️  실패/미설치 (${#failed_tools[@]}개):${NC}"
    for tool in "${failed_tools[@]}"; do
        log "  - $tool"
        telegram_message+="⚠️ $tool\n"
    done
fi

log ""
log "현재 버전:"
log "  Claude Code: $(get_version 'claude')"
log "  OpenCode: $(get_version 'opencode')"
log "  Oh-My-OpenCode: $(get_version 'oh-my-opencode')"
log "  QMD: $(get_version 'qmd')"

telegram_message+="\n현재 버전:\n"
telegram_message+="  Claude: $(get_version 'claude')\n"
telegram_message+="  OpenCode: $(get_version 'opencode')\n"
telegram_message+="  Oh-My-OpenCode: $(get_version 'oh-my-opencode')\n"
telegram_message+="  QMD: $(get_version 'qmd')"

log "${BLUE}========================================${NC}"

# 실행 완료 시간 및 소요 시간
END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
END_TIMESTAMP=$(date +%s)
DURATION=$((END_TIMESTAMP - START_TIMESTAMP))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

log ""
log "${BLUE}⏱️  실행 완료 시간: $END_TIME${NC}"
log "${BLUE}⏱️  소요 시간: ${DURATION_MIN}분 ${DURATION_SEC}초${NC}"

telegram_message+="\n⏱️ <b>완료 시간</b>: $END_TIME"
telegram_message+="\n⏱️ <b>소요 시간</b>: ${DURATION_MIN}분 ${DURATION_SEC}초"

# Telegram 알림
send_telegram "$telegram_message"

log ""
log "✅ 자동 업데이트 완료"
log "📝 로그: $LOG_FILE"
log "💾 백업: $BACKUP_DIR"

# 최신 로그 심볼릭 링크 생성
ln -sf "$LOG_FILE" "$LOG_LATEST"

# 30일 이상 된 로그 파일 삭제
find "$HOME/.claude" -name "auto_update_*.log" -type f -mtime +30 -delete 2>/dev/null || true
log "🗑️  30일 이상 된 로그 자동 삭제"
