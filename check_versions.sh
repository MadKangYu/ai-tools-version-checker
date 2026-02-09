#!/bin/bash

# AI Tools 최신 버전 체크 스크립트
# 사용법: ./check_versions.sh [telegram|log|stdout]

set -euo pipefail

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 파일
LOG_FILE="$HOME/.claude/version_check.log"
mkdir -p "$HOME/.claude"

# Telegram 설정 (환경변수에서 로드)
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

# 출력 모드
OUTPUT_MODE="${1:-stdout}"

log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # 터미널 출력
    if [[ "$OUTPUT_MODE" == "stdout" ]] || [[ "$OUTPUT_MODE" == "all" ]]; then
        echo -e "$message"
    fi

    # 파일 로그
    if [[ "$OUTPUT_MODE" == "log" ]] || [[ "$OUTPUT_MODE" == "all" ]]; then
        echo "[$timestamp] $message" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
    fi
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

get_github_latest_version() {
    local repo="$1"
    local version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name"' | sed -E 's/.*"tag_name": "v?([^"]+)".*/\1/')
    echo "$version"
}

get_installed_version() {
    local tool="$1"
    local version=""

    case "$tool" in
        "claude")
            version=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "not_installed")
            ;;
        "crush")
            version=$(crush --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "not_installed")
            ;;
        "qmd")
            version=$(qmd --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "not_installed")
            ;;
    esac

    echo "$version"
}

compare_versions() {
    local installed="$1"
    local latest="$2"

    if [[ "$installed" == "not_installed" ]]; then
        echo "not_installed"
        return
    fi

    if [[ "$installed" == "$latest" ]]; then
        echo "up_to_date"
    else
        echo "outdated"
    fi
}

log "${BLUE}========================================${NC}"
log "${BLUE}🔍 AI Tools 버전 체크 시작${NC}"
log "${BLUE}========================================${NC}"
log ""

telegram_message="🤖 <b>AI Tools 버전 체크</b>\n\n"
has_updates=false

# 1. Claude Code
log "${YELLOW}[1/3] Claude Code 체크...${NC}"
claude_installed=$(get_installed_version "claude")
claude_latest=$(get_github_latest_version "anthropics/claude-code")
claude_status=$(compare_versions "$claude_installed" "$claude_latest")

case "$claude_status" in
    "up_to_date")
        log "  ${GREEN}✅ Claude Code: $claude_installed (최신)${NC}"
        telegram_message+="✅ <b>Claude Code</b>: $claude_installed (최신)\n"
        ;;
    "outdated")
        log "  ${RED}🔄 Claude Code: $claude_installed → $claude_latest (업데이트 필요)${NC}"
        telegram_message+="🔄 <b>Claude Code</b>: $claude_installed → $claude_latest\n"
        telegram_message+="   업데이트: <code>brew upgrade claude-code</code>\n"
        has_updates=true
        ;;
    "not_installed")
        log "  ${RED}❌ Claude Code: 미설치${NC}"
        telegram_message+="❌ <b>Claude Code</b>: 미설치\n"
        ;;
esac
log ""

# 2. Crush (ex-OpenCode)
log "${YELLOW}[2/3] Crush (OpenCode) 체크...${NC}"
crush_installed=$(get_installed_version "crush")
crush_latest=$(get_github_latest_version "charmbracelet/crush")
crush_status=$(compare_versions "$crush_installed" "$crush_latest")

case "$crush_status" in
    "up_to_date")
        log "  ${GREEN}✅ Crush: $crush_installed (최신)${NC}"
        telegram_message+="✅ <b>Crush</b>: $crush_installed (최신)\n"
        ;;
    "outdated")
        log "  ${RED}🔄 Crush: $crush_installed → $crush_latest (업데이트 필요)${NC}"
        telegram_message+="🔄 <b>Crush</b>: $crush_installed → $crush_latest\n"
        telegram_message+="   업데이트: <code>brew upgrade charmbracelet/tap/crush</code>\n"
        has_updates=true
        ;;
    "not_installed")
        log "  ${RED}❌ Crush: 미설치${NC}"
        telegram_message+="❌ <b>Crush</b>: 미설치\n"
        ;;
esac
log ""

# 3. QMD
log "${YELLOW}[3/3] QMD 체크...${NC}"
qmd_installed=$(get_installed_version "qmd")
qmd_latest=$(get_github_latest_version "tobi/qmd")
qmd_status=$(compare_versions "$qmd_installed" "$qmd_latest")

case "$qmd_status" in
    "up_to_date")
        log "  ${GREEN}✅ QMD: $qmd_installed (최신)${NC}"
        telegram_message+="✅ <b>QMD</b>: $qmd_installed (최신)\n"
        ;;
    "outdated")
        log "  ${RED}🔄 QMD: $qmd_installed → $qmd_latest (업데이트 필요)${NC}"
        telegram_message+="🔄 <b>QMD</b>: $qmd_installed → $qmd_latest\n"
        telegram_message+="   업데이트: <code>bun install -g https://github.com/tobi/qmd</code>\n"
        has_updates=true
        ;;
    "not_installed")
        log "  ${RED}❌ QMD: 미설치${NC}"
        telegram_message+="❌ <b>QMD</b>: 미설치\n"
        ;;
esac
log ""

# 요약
log "${BLUE}========================================${NC}"
if $has_updates; then
    log "${RED}⚠️  업데이트 필요한 도구가 있습니다!${NC}"
else
    log "${GREEN}🎉 모든 도구가 최신 버전입니다!${NC}"
fi
log "${BLUE}========================================${NC}"

# Telegram 알림
if [[ "$OUTPUT_MODE" == "telegram" ]] || [[ "$OUTPUT_MODE" == "all" ]]; then
    if $has_updates; then
        telegram_message+="\n⚠️ <b>업데이트 필요!</b>"
    else
        telegram_message+="\n🎉 <b>모두 최신!</b>"
    fi
    send_telegram "$telegram_message"
fi

# 종료 코드
if $has_updates; then
    exit 1
else
    exit 0
fi
