# Secrets Management

Secure secrets management for your development environment. No more hardcoded API keys!

## Overview

The `secrets_manager.sh` script provides a unified interface for loading secrets from multiple backends:

1. **1Password CLI** (Recommended) - If you use 1Password
2. **Bitwarden CLI** - Free, open-source alternative
3. **GPG Encrypted File** - Simple, self-contained option
4. **Environment Variables** - Fallback mode

Secrets are cached for 1 hour to minimize backend calls while maintaining security.

## Quick Start

Your `.rafi-config.sh` is already configured to use the secrets manager. Choose and set up one backend below:

### Option A: 1Password CLI (Recommended)

**Install:**
```bash
brew install 1password-cli
```

**Setup:**
1. Sign in to 1Password:
   ```bash
   eval $(op signin)
   ```

2. Store your secrets in 1Password (using the app or CLI):
   ```bash
   # Using 1Password app:
   # Create items in your "Personal" vault (or adjust vault name in secrets_manager.sh):
   #   - Item name: "OpenAI" → field: "credential" → value: your-api-key
   #   - Item name: "Anthropic" → field: "credential" → value: your-api-key
   #   - Item name: "Journal" → field: "password" → value: your-journal-key

   # Or using CLI:
   op item create --category=Login --title="OpenAI" \
     --vault="Personal" credential=sk-your-openai-key

   op item create --category=Login --title="Anthropic" \
     --vault="Personal" credential=sk-ant-your-anthropic-key
   ```

3. Update `secrets_manager.sh` if your vault name isn't "Personal":
   ```bash
   # Edit line ~52-54 to match your vault structure
   export OPENAI_API_KEY=$(op read "op://YourVault/OpenAI/credential")
   ```

**Usage:**
```bash
# Sign in once per session (or add to .rafi-config.sh)
eval $(op signin)

# Open new terminal - secrets auto-load!
# Verify:
echo $OPENAI_API_KEY | head -c 20
```

### Option B: Bitwarden CLI

**Install:**
```bash
brew install bitwarden-cli
```

**Setup:**
1. Login to Bitwarden:
   ```bash
   bw login
   ```

2. Store your secrets:
   ```bash
   # Create secure note items in Bitwarden:
   bw get template item | jq '.type = 2 | .name = "OpenAI API Key" | .notes = "sk-your-key"' | bw encode | bw create item
   ```

3. Unlock vault and export session:
   ```bash
   export BW_SESSION=$(bw unlock --raw)
   ```

**Usage:**
```bash
# Unlock once per session
export BW_SESSION=$(bw unlock --raw)

# Add to .rafi-config.sh for auto-unlock:
# export BW_SESSION=$(bw unlock --raw)

# Open new terminal - secrets auto-load!
```

### Option C: GPG Encrypted File (Simple)

**Setup:**
1. Install GPG (if not already installed):
   ```bash
   brew install gnupg
   ```

2. Create a secrets file:
   ```bash
   cat > ~/.secrets << 'EOF'
export OPENAI_API_KEY="sk-your-openai-key"
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"
export JOURNAL_KEY="your-journal-key"
EOF
   ```

3. Encrypt it:
   ```bash
   gpg --symmetric --cipher-algo AES256 ~/.secrets
   mv ~/.secrets.gpg ~/.secrets.gpg
   rm ~/.secrets  # Remove unencrypted version!
   ```

4. Set a strong passphrase when prompted

**Usage:**
```bash
# Open new terminal
# Enter GPG passphrase when prompted
# Secrets auto-load!
```

**To update secrets:**
```bash
# Decrypt, edit, re-encrypt
gpg --decrypt ~/.secrets.gpg > ~/.secrets
nano ~/.secrets
gpg --symmetric --cipher-algo AES256 ~/.secrets
mv ~/.secrets.gpg ~/.secrets.gpg
rm ~/.secrets
```

### Option D: Temporary Environment Variables (Not Recommended)

For quick testing only:

```bash
# Set manually in each session
export OPENAI_API_KEY="sk-your-key"
export ANTHROPIC_API_KEY="sk-ant-your-key"
```

## Migration from Old Config

Your old `.rafi-config.sh` has been backed up to:
```
~/.rafi-config.sh.backup-TIMESTAMP
```

**IMPORTANT: Rotate Your Keys!**

Since your API keys were previously hardcoded in plaintext, you should rotate them:

1. **OpenAI:** https://platform.openai.com/api-keys
   - Revoke old key
   - Create new key
   - Store in your chosen secrets backend

2. **Anthropic:** https://console.anthropic.com/settings/keys
   - Revoke old key
   - Create new key
   - Store in your chosen secrets backend

3. **Journal Key:**
   - If this is critical, generate a new one
   - Store in your chosen secrets backend

## Verification

Test that secrets are loading correctly:

```bash
# Open a new terminal and run:
source ~/.rafi-config.sh

# Check if secrets loaded (shows first 20 chars):
echo $OPENAI_API_KEY | head -c 20
echo $ANTHROPIC_API_KEY | head -c 20

# Or validate all secrets:
~/Projects/devops-toolkit/secrets/secrets_manager.sh validate
```

## Troubleshooting

### Secrets not loading

```bash
# Check which backend is being used:
~/Projects/devops-toolkit/secrets/secrets_manager.sh load

# Clear cache and retry:
~/Projects/devops-toolkit/secrets/secrets_manager.sh clear-cache
source ~/.rafi-config.sh
```

### 1Password "not signed in" error

```bash
eval $(op signin)
```

### Bitwarden "vault locked" error

```bash
export BW_SESSION=$(bw unlock --raw)
```

### GPG passphrase prompts every time

This is normal for security. To cache the passphrase:

```bash
# Edit ~/.gnupg/gpg-agent.conf
echo "default-cache-ttl 3600" >> ~/.gnupg/gpg-agent.conf
echo "max-cache-ttl 7200" >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent
```

## Security Best Practices

1. **Never commit secrets to git**
   - Use `.env.example` templates instead
   - Add `.env` to `.gitignore`

2. **Rotate keys periodically**
   - Set calendar reminders to rotate every 90 days
   - Rotate immediately if you suspect exposure

3. **Use different keys for different environments**
   - Production vs development
   - Personal vs work

4. **Audit secrets access**
   - Check 1Password/Bitwarden access logs
   - Monitor API usage dashboards

5. **Backup your secrets securely**
   - 1Password/Bitwarden handle this automatically
   - For GPG: backup `~/.secrets.gpg` to secure location

## Cache Management

Secrets are cached for 1 hour to reduce backend calls. The cache file is:
```
~/.secrets_cache
```

**Clear cache:**
```bash
~/Projects/devops-toolkit/secrets/secrets_manager.sh clear-cache
```

Cache is automatically invalidated after 1 hour.

## Cross-Machine Sync

To use this setup on multiple machines:

1. Clone devops-toolkit on each machine:
   ```bash
   cd ~/Projects
   git clone https://github.com/0xrafi/devops-toolkit.git
   ```

2. Copy your shell config:
   ```bash
   # On new machine, copy .rafi-config.sh from this repo
   # It will automatically use the secrets manager
   ```

3. Set up your chosen secrets backend on the new machine

4. Your secrets stay secure and never leave your secrets manager!

## Contributing

If you add new secrets, update the secrets_manager.sh to include them:

1. Edit `secrets_manager.sh`
2. Add loading logic in each `load_from_*` function
3. Update `save_to_cache` and `validate_secrets` functions
4. Document in this README

## Support

For issues or questions:
- Check the troubleshooting section above
- Review secrets_manager.sh comments
- Open an issue in the devops-toolkit repo
