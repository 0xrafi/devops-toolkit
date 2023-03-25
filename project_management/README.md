# Project Management

In this folder, I've collected some scripts that help me manage my projects more efficiently. These scripts assist with tasks like syncing GitHub repositories, managing code snippets, and more.

## Scripts

### Auto-sync GitHub Repositories (`auto_sync_repos.sh`)

Automates the process of syncing local GitHub repos with their remote counterparts, allowing you to update all repos at once or choose individual repos to update; fetches changes from the remote repos and merges them using a fast-forward merge strategy.

### Create PR (`create_pr.sh`)

Pushes your local feature branch and creates a PR on main, opening up a window in your browser. Only works on Github.

#### Usage

1. Set the `REPOS_DIR` environment variable to the path of your local GitHub repositories.
2. Run the script: `./auto_sync_repos.sh`
3. Choose to update all repositories, select repositories to update, or quit.

#### Dependencies

- `git`: Ensure that Git is installed on your system.

As I create more project management scripts, I'll add them to this folder and update the usage instructions in the respective script files.

