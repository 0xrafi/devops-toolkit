# Project Management

In this folder, I've collected some scripts that help me manage my projects more efficiently. These scripts assist with tasks like syncing GitHub repositories, managing code snippets, and more.

## Scripts

### Auto-sync GitHub Repositories (`auto_sync_repos.sh`)

This script automates the process of syncing your local GitHub repositories with their remote counterparts. It allows you to either update all repositories at once or choose individual repositories to update. It fetches changes from the remote repositories and merges them using a fast-forward merge strategy.

#### Usage

1. Set the `REPOS_DIR` environment variable to the path of your local GitHub repositories.
2. Run the script: `./auto_sync_repos.sh`
3. Choose to update all repositories, select repositories to update, or quit.

#### Dependencies

- `git`: Ensure that Git is installed on your system.

As I create more project management scripts, I'll add them to this folder and update the usage instructions in the respective script files.

