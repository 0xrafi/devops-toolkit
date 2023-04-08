#!/bin/bash

function get_current_branch() {
    git symbolic-ref --short HEAD
}

function push_current_branch() {
    local current_branch=$1
    git push -u origin $current_branch
}

function get_remote_url() {
    git config --get remote.origin.url
}

function validate_remote_url() {
    local remote_url=$1

    if [ -z "$remote_url" ]; then
        echo "Error: No remote URL found. Please set up a remote repo on Github and try again."
        exit 1
    fi

    if [[ ! $remote_url =~ ^https:\/\/github\.com\/[a-zA-Z0-9._-]+\/[a-zA-Z0-9._-]+\.git$ ]]; then
        echo "Error: Invalid remote URL. Please set up a valid remote repo on Github and try again."
        exit 1
    fi
}

function get_user_and_repo() {
    local remote_url=$1
    echo $remote_url | sed -E 's/.*github.com[:\/]//g' | sed 's/\.git$//g'
}

function open_pull_request() {
    local user_and_repo=$1
    local current_branch=$2
    local pr_url="https://github.com/$user_and_repo/compare/main...$current_branch?expand=1"
    open $pr_url
}

main() {
    local remote_url=$(get_remote_url)
    validate_remote_url $remote_url

    local current_branch=$(get_current_branch)
    push_current_branch $current_branch

    local user_and_repo=$(get_user_and_repo $remote_url)
    open_pull_request $user_and_repo $current_branch
}

main
