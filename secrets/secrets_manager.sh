#!/bin/bash
# secrets_manager.sh - Secure secrets management for shell environment
# Supports multiple backends: 1Password CLI, Bitwarden CLI, or encrypted file

# Use -e and -o pipefail, but not -u (causes issues when sourced)
set -eo pipefail

# Configuration
SECRETS_FILE="${HOME}/.secrets.gpg"
SECRETS_CACHE_FILE="${HOME}/.secrets_cache"
CACHE_TTL=3600  # Cache secrets for 1 hour

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[secrets]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[secrets]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[secrets]${NC} $1" >&2
}

# Check if cache is valid
is_cache_valid() {
    if [[ ! -f "$SECRETS_CACHE_FILE" ]]; then
        return 1
    fi

    local cache_age=$(($(date +%s) - $(stat -f %m "$SECRETS_CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $cache_age -gt $CACHE_TTL ]]; then
        return 1
    fi

    return 0
}

# Load from cache
load_from_cache() {
    if is_cache_valid; then
        source "$SECRETS_CACHE_FILE" 2>/dev/null && return 0
    fi
    return 1
}

# Save to cache
save_to_cache() {
    cat > "$SECRETS_CACHE_FILE" << EOF
# Auto-generated secrets cache - expires in $CACHE_TTL seconds
# Generated: $(date)
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
export JOURNAL_KEY="${JOURNAL_KEY:-}"
EOF
    chmod 600 "$SECRETS_CACHE_FILE"
}

# 1Password CLI support
load_from_1password() {
    if ! command -v op &> /dev/null; then
        return 1
    fi

    log_info "Loading secrets from 1Password..."

    # Check if CLI is connected (with desktop app, no explicit signin needed)
    if ! op vault list &> /dev/null; then
        log_warn "Cannot connect to 1Password. Make sure the desktop app is running and CLI integration is enabled."
        return 1
    fi

    # Load secrets from 1Password items
    export OPENAI_API_KEY=$(op item get "OpenAI API Key" --fields credential --reveal 2>/dev/null || echo "")
    export ANTHROPIC_API_KEY=$(op item get "Anthropic API Key" --fields credential --reveal 2>/dev/null || echo "")
    export JOURNAL_KEY=$(op item get "Journal Encryption Key" --fields credential --reveal 2>/dev/null || echo "")

    if [[ -n "$OPENAI_API_KEY" ]] || [[ -n "$ANTHROPIC_API_KEY" ]]; then
        log_info "Successfully loaded secrets from 1Password"
        save_to_cache
        return 0
    fi

    return 1
}

# Bitwarden CLI support
load_from_bitwarden() {
    if ! command -v bw &> /dev/null; then
        return 1
    fi

    log_info "Loading secrets from Bitwarden..."

    # Check if unlocked
    if [[ -z "${BW_SESSION:-}" ]]; then
        log_warn "Bitwarden vault is locked. Run: export BW_SESSION=\$(bw unlock --raw)"
        return 1
    fi

    # Load secrets (adjust these item names to match your Bitwarden vault)
    export OPENAI_API_KEY=$(bw get password "OpenAI API Key" 2>/dev/null || echo "")
    export ANTHROPIC_API_KEY=$(bw get password "Anthropic API Key" 2>/dev/null || echo "")
    export JOURNAL_KEY=$(bw get password "Journal Key" 2>/dev/null || echo "")

    if [[ -n "$OPENAI_API_KEY" ]] || [[ -n "$ANTHROPIC_API_KEY" ]]; then
        log_info "Successfully loaded secrets from Bitwarden"
        save_to_cache
        return 0
    fi

    return 1
}

# GPG encrypted file support
load_from_gpg_file() {
    if [[ ! -f "$SECRETS_FILE" ]]; then
        return 1
    fi

    if ! command -v gpg &> /dev/null; then
        log_warn "GPG not installed but $SECRETS_FILE exists"
        return 1
    fi

    log_info "Loading secrets from encrypted file..."

    # Decrypt and source the file
    if gpg --quiet --decrypt "$SECRETS_FILE" 2>/dev/null | source /dev/stdin; then
        log_info "Successfully loaded secrets from encrypted file"
        save_to_cache
        return 0
    fi

    return 1
}

# Manual/fallback mode - prompts user
load_manual() {
    log_warn "No secrets backend configured. Using manual entry mode."
    log_info "Secrets will be loaded from environment or you'll be prompted."

    # Check if already set in environment
    if [[ -n "${OPENAI_API_KEY:-}" ]] && [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
        log_info "Secrets already present in environment"
        return 0
    fi

    log_warn "Set up a secrets backend for better security:"
    log_warn "  1. Install 1Password CLI: https://developer.1password.com/docs/cli"
    log_warn "  2. Install Bitwarden CLI: https://bitwarden.com/help/cli/"
    log_warn "  3. Create encrypted file: see ${HOME}/.devops-toolkit-help/secrets-setup.md"

    return 1
}

# Main loading function
load_secrets() {
    # Try cache first for performance
    if load_from_cache; then
        return 0
    fi

    # Try each backend in order of preference
    if load_from_1password; then
        return 0
    fi

    if load_from_bitwarden; then
        return 0
    fi

    if load_from_gpg_file; then
        return 0
    fi

    # Fallback to manual/environment
    load_manual
    return $?
}

# Export validation function
validate_secrets() {
    local missing=0

    if [[ -z "${OPENAI_API_KEY:-}" ]]; then
        log_warn "OPENAI_API_KEY not set"
        ((missing++))
    fi

    if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
        log_warn "ANTHROPIC_API_KEY not set"
        ((missing++))
    fi

    if [[ $missing -gt 0 ]]; then
        log_warn "$missing required secret(s) missing"
        return 1
    fi

    return 0
}

# Clear secrets cache
clear_cache() {
    rm -f "$SECRETS_CACHE_FILE"
    log_info "Secrets cache cleared"
}

# Main execution
main() {
    case "${1:-load}" in
        load)
            load_secrets
            ;;
        validate)
            validate_secrets
            ;;
        clear-cache)
            clear_cache
            ;;
        *)
            echo "Usage: $0 {load|validate|clear-cache}"
            exit 1
            ;;
    esac
}

# If sourced, just load secrets. If executed, run main.
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    main "$@"
else
    load_secrets
fi
