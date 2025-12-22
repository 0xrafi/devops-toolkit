#!/bin/bash
# setup_secrets.sh - Interactive setup for secrets management

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    Secure Secrets Management Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if already configured
if [[ -f ~/.secrets.gpg ]] || command -v op &>/dev/null || command -v bw &>/dev/null; then
    echo -e "${YELLOW}Looks like you might already have a secrets backend configured.${NC}"
    echo ""
fi

echo "Choose your secrets management backend:"
echo ""
echo "  1) 1Password CLI (Recommended - best UX if you use 1Password)"
echo "  2) Bitwarden CLI (Free, open-source)"
echo "  3) GPG Encrypted File (Simple, self-contained)"
echo "  4) Skip setup (I'll configure manually)"
echo ""
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}Setting up 1Password CLI...${NC}"
        echo ""

        if ! command -v op &>/dev/null; then
            echo "Installing 1Password CLI..."
            if command -v brew &>/dev/null; then
                brew install 1password-cli
            else
                echo -e "${RED}Error: Homebrew not found. Install from: https://developer.1password.com/docs/cli${NC}"
                exit 1
            fi
        else
            echo -e "${GREEN}✓ 1Password CLI already installed${NC}"
        fi

        echo ""
        echo "Next steps:"
        echo "  1. Sign in to 1Password CLI:"
        echo "     ${YELLOW}eval \$(op signin)${NC}"
        echo ""
        echo "  2. Store your secrets in 1Password:"
        echo "     ${YELLOW}op item create --category=Login --title='OpenAI' --vault='Personal' credential=sk-your-key${NC}"
        echo "     ${YELLOW}op item create --category=Login --title='Anthropic' --vault='Personal' credential=sk-ant-your-key${NC}"
        echo ""
        echo "  3. Open a new terminal - secrets will auto-load!"
        echo ""
        echo -e "${BLUE}📖 See secrets/README.md for detailed instructions${NC}"
        ;;

    2)
        echo ""
        echo -e "${GREEN}Setting up Bitwarden CLI...${NC}"
        echo ""

        if ! command -v bw &>/dev/null; then
            echo "Installing Bitwarden CLI..."
            if command -v brew &>/dev/null; then
                brew install bitwarden-cli
            else
                echo -e "${RED}Error: Homebrew not found. Install from: https://bitwarden.com/help/cli/${NC}"
                exit 1
            fi
        else
            echo -e "${GREEN}✓ Bitwarden CLI already installed${NC}"
        fi

        echo ""
        echo "Next steps:"
        echo "  1. Login to Bitwarden:"
        echo "     ${YELLOW}bw login${NC}"
        echo ""
        echo "  2. Unlock and set session:"
        echo "     ${YELLOW}export BW_SESSION=\$(bw unlock --raw)${NC}"
        echo ""
        echo "  3. Create secure notes for your API keys in Bitwarden app or CLI"
        echo ""
        echo "  4. Open a new terminal - secrets will auto-load!"
        echo ""
        echo -e "${BLUE}📖 See secrets/README.md for detailed instructions${NC}"
        ;;

    3)
        echo ""
        echo -e "${GREEN}Setting up GPG Encrypted File...${NC}"
        echo ""

        if ! command -v gpg &>/dev/null; then
            echo "Installing GnuPG..."
            if command -v brew &>/dev/null; then
                brew install gnupg
            else
                echo -e "${RED}Error: Homebrew not found. Install GPG manually.${NC}"
                exit 1
            fi
        else
            echo -e "${GREEN}✓ GPG already installed${NC}"
        fi

        echo ""
        read -p "Would you like to create the secrets file now? [y/N]: " create_now

        if [[ "$create_now" =~ ^[Yy]$ ]]; then
            # Copy template to temp location
            cp "$(dirname "$0")/.env.template" /tmp/secrets_temp

            echo ""
            echo -e "${YELLOW}Opening editor to enter your secrets...${NC}"
            echo "Replace the placeholder values with your actual secrets."
            echo ""
            read -p "Press Enter to continue..."

            ${EDITOR:-nano} /tmp/secrets_temp

            echo ""
            echo "Encrypting secrets file..."
            gpg --symmetric --cipher-algo AES256 /tmp/secrets_temp

            mv /tmp/secrets_temp.gpg ~/.secrets.gpg
            rm -f /tmp/secrets_temp

            echo -e "${GREEN}✓ Secrets file created and encrypted at ~/.secrets.gpg${NC}"
            echo ""
            echo "Open a new terminal - secrets will auto-load!"
            echo "(You'll be prompted for your GPG passphrase)"
        else
            echo ""
            echo "Manual setup:"
            echo "  1. Copy template:"
            echo "     ${YELLOW}cp $(dirname "$0")/.env.template ~/.secrets${NC}"
            echo ""
            echo "  2. Edit and add your secrets:"
            echo "     ${YELLOW}nano ~/.secrets${NC}"
            echo ""
            echo "  3. Encrypt the file:"
            echo "     ${YELLOW}gpg --symmetric --cipher-algo AES256 ~/.secrets${NC}"
            echo "     ${YELLOW}mv ~/.secrets.gpg ~/.secrets.gpg${NC}"
            echo "     ${YELLOW}rm ~/.secrets${NC}"
            echo ""
        fi

        echo -e "${BLUE}📖 See secrets/README.md for detailed instructions${NC}"
        ;;

    4)
        echo ""
        echo -e "${YELLOW}Skipping automated setup.${NC}"
        echo ""
        echo -e "${BLUE}📖 Read secrets/README.md for manual setup instructions${NC}"
        ;;

    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}    Setup Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Rotate your API keys!${NC}"
echo ""
echo "Since your old keys were in plaintext, you should rotate them:"
echo "  • OpenAI: https://platform.openai.com/api-keys"
echo "  • Anthropic: https://console.anthropic.com/settings/keys"
echo ""
echo "Your old config is backed up at:"
echo "  ~/.rafi-config.sh.backup-*"
echo ""
