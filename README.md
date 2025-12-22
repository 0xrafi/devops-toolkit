# DevOps Toolkit

A curated collection of shell scripts and automation tools for developer productivity, server management, and secure secrets handling.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/0xrafi/devops-toolkit.git
cd devops-toolkit

# Install scripts globally (adds symlinks to /usr/local/bin)
sudo ./install.sh

# Set up secrets management (interactive wizard)
./secrets/setup_secrets.sh
```

## 📁 What's Inside

### 🔐 Secrets Management (`secrets/`)

**Secure secrets management for shell environments** - No more hardcoded API keys!

- **Multi-backend support:** 1Password CLI, Bitwarden CLI, or GPG encrypted files
- **Auto-loading:** Secrets load automatically when you open a new terminal
- **Secure caching:** 1-hour TTL to reduce backend calls while maintaining security
- **Fallback modes:** Graceful degradation if backend unavailable

**Quick setup:**
```bash
./secrets/setup_secrets.sh
```

**Documentation:** See [`secrets/README.md`](secrets/README.md) for complete setup guide.

**Key features:**
- Load secrets from 1Password: `op read "op://vault/item/field"`
- Load from Bitwarden: `bw get password "item-name"`
- Load from GPG file: `~/.secrets.gpg`
- Cache management: `secrets_manager.sh clear-cache`

---

### 🖥️ Automation (`automation/`)

#### `remote_connect.sh`

**SSH automation for remote servers with Wake-on-LAN support**

Connects to a remote Manjaro server via a Raspberry Pi jump host. Handles:
- Wake-on-LAN signal to wake server
- SSH ProxyJump configuration
- Optional SSH tunneling for port forwarding
- Graceful shutdown with confirmation

**Usage:**
```bash
remote_connect
# Follow interactive prompts for tunneling options
```

**Environment variables required:**
```bash
export REMOTE_USER="your-username"
export REMOTE_HOST="your.duckdns.org"
export SERVER_USER="server-username"
export SERVER_IP="192.168.x.x"
export MAC_ADDRESS="aa:bb:cc:dd:ee:ff"
export MANJARO_SSH_ALIAS="manjaro-local"  # From ~/.ssh/config
```

**Dependencies:**
- `etherwake` on jump host (for Wake-on-LAN)
- SSH ProxyJump configured in `~/.ssh/config`

**Example SSH config:**
```
Host rpi-remote
  Hostname your.duckdns.org
  User rafi

Host manjaro-local
  Hostname 192.168.x.x
  User rafi
  ProxyJump rpi-remote
```

---

### 📦 Project Management (`project_management/`)

#### `auto_sync_repos.sh`

**Batch sync multiple git repositories**

Automates syncing local repos with their remotes using fast-forward merges.

**Usage:**
```bash
export REPOS_DIR="$HOME/Projects"
auto_sync_repos

# Options:
# 1. Update all repositories
# 2. Select repositories to update
# 3. Quit
```

**Features:**
- Interactive menu for selective syncing
- Fast-forward merge strategy (safe, won't overwrite local changes)
- Batch mode for updating all repos at once

---

#### `create_pr.sh`

**Quick PR creation workflow**

Pushes current branch and opens GitHub PR creation page in your browser.

**Usage:**
```bash
# From your feature branch
create_pr
# Automatically:
# 1. Pushes current branch to origin
# 2. Opens PR creation page: github.com/user/repo/compare/main...your-branch
```

**Requirements:**
- Git repository with GitHub remote
- Valid HTTPS remote URL

**Note:** For more advanced PR creation, consider using `gh pr create` from [GitHub CLI](https://cli.github.com/).

---

## 🛠️ Installation

### Global Installation (Recommended)

Install all scripts globally so you can run them from anywhere:

```bash
cd ~/devops-toolkit
sudo ./install.sh
```

This creates symlinks in `/usr/local/bin/` for all scripts:
- `remote_connect` → `automation/remote_connect.sh`
- `auto_sync_repos` → `project_management/auto_sync_repos.sh`
- `create_pr` → `project_management/create_pr.sh`

**Note:** The installer skips `secrets/` scripts as they're meant to be sourced, not executed directly.

### Manual Usage

You can also run scripts directly without installation:

```bash
./automation/remote_connect.sh
./project_management/auto_sync_repos.sh
```

---

## 🔧 Configuration

### Shell Integration

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Load secrets automatically
if [[ -f "${HOME}/Projects/devops-toolkit/secrets/secrets_manager.sh" ]]; then
  source "${HOME}/Projects/devops-toolkit/secrets/secrets_manager.sh"
fi

# Set up environment variables for automation scripts
export REMOTE_USER="your-username"
export REMOTE_HOST="your.duckdns.org"
export SERVER_IP="192.168.x.x"
export MAC_ADDRESS="aa:bb:cc:dd:ee:ff"
export MANJARO_SSH_ALIAS="manjaro-local"

# For auto_sync_repos
export REPOS_DIR="$HOME/Projects"
```

### SSH Configuration

For `remote_connect.sh`, set up SSH ProxyJump in `~/.ssh/config`:

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa

Host jump-host
  Hostname your-jump-host.com
  User your-username

Host remote-server
  Hostname 192.168.x.x
  User your-username
  ProxyJump jump-host
```

---

## 📚 Documentation

- **Secrets Management:** [`secrets/README.md`](secrets/README.md) - Complete guide to secure secrets handling
- **Main README:** This file - Overview and quick reference
- **Script Comments:** Each script has detailed inline documentation

---

## 🔄 Updating

```bash
cd ~/devops-toolkit
git pull

# Re-run installer if new scripts were added
sudo ./install.sh
```

The installer tracks its location in `~/.devops_toolkit`, so you can run it from anywhere after the first install.

---

## 🗂️ Repository Structure

```
devops-toolkit/
├── README.md                      # This file
├── install.sh                     # Global installation script
├── automation/                    # Server & SSH automation
│   └── remote_connect.sh         # Remote server connection with WoL
├── project_management/            # Git & project workflows
│   ├── auto_sync_repos.sh        # Batch git sync
│   └── create_pr.sh              # Quick PR creation
└── secrets/                       # Secure secrets management
    ├── README.md                 # Detailed secrets documentation
    ├── secrets_manager.sh        # Core secrets loading logic
    ├── setup_secrets.sh          # Interactive setup wizard
    └── .env.template             # Template for GPG method
```

---

## 🛡️ Security Best Practices

1. **Never commit secrets to git**
   - Use the secrets management system
   - Add `.env` to `.gitignore`
   - Use `.env.example` templates

2. **Rotate API keys periodically**
   - Set calendar reminders for 90-day rotation
   - Rotate immediately if you suspect exposure

3. **Use SSH keys, not passwords**
   - Configure SSH key-based authentication
   - Use `ssh-add` to manage keys

4. **Review scripts before running**
   - All scripts in this repo are open source
   - Check what environment variables are used
   - Understand what each script does

---

## 🤝 Contributing

This is a personal toolkit, but improvements are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📝 License

MIT License - Use freely, modify as needed, no warranties provided.

---

## 🆘 Troubleshooting

**Scripts not found after installation:**
```bash
# Check if /usr/local/bin is in your PATH
echo $PATH | grep "/usr/local/bin"

# Re-run installer
cd ~/devops-toolkit
sudo ./install.sh
```

**Secrets not loading:**
```bash
# Check secrets manager status
~/Projects/devops-toolkit/secrets/secrets_manager.sh validate

# Clear cache and reload
~/Projects/devops-toolkit/secrets/secrets_manager.sh clear-cache
source ~/.zshrc
```

**Remote connect not working:**
```bash
# Verify SSH config
cat ~/.ssh/config | grep -A 5 "Host manjaro-local"

# Test jump host connection
ssh rpi-remote "echo 'Jump host OK'"

# Check environment variables
echo $REMOTE_HOST $SERVER_IP $MAC_ADDRESS
```

---

## 📮 Contact

Issues and questions: [GitHub Issues](https://github.com/0xrafi/devops-toolkit/issues)

---

**Last updated:** December 2025
