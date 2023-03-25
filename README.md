# DevOps-Toolkit

Hey there! 👋 Welcome to my DevOps-Toolkit. I'm just starting out with this repo, but my goal is to put together a collection of practical and effective scripts that have helped me streamline and automate my daily tasks as a developer. I work with blockchain, frontend development, and machine learning, so I thought these scripts might be helpful for others too.

## Categories

For now, I've added a script for automating the SSH connection to my remote server via a Raspberry Pi jump host and another for quickly updating project dependencies. As I create more scripts, I'll organize them into the following categories:

- **Deployment**: Tools for automating the deployment process for my projects.
- **Automation**: Scripts that make my life easier by automating tasks like environment setup and backups.
- **Monitoring**: Tools to keep an eye on system performance and resources.
- **Project Management**: Tools that help me manage tasks, code snippets, and boilerplates.
- **Misc**: Other useful scripts that don't fit into the main categories but have made a difference in my workflow.

Feel free to explore and follow the usage instructions provided in each `README.md` file.
## Installation

To make the `devops-toolkit` scripts easily accessible from your terminal, run the provided `install.sh` script. This script creates symbolic links for all executable scripts in the `/usr/local/bin` directory, allowing you to run the scripts by their name from any location.

1. Clone the repository: `git clone https://github.com/your-username/devops-toolkit.git`
2. Change to the `devops-toolkit` directory: `cd devops-toolkit`
3. Run the `install.sh` script: `./install.sh`

Now you can run any script by its name from your terminal. The `install.sh` script will also ensure that all the scripts are marked as executable.

**Note**: If you add new scripts to the repository, run the `install.sh` script again to update the symbolic links and mark new scripts as executable.

