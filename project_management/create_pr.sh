#!/bin/bash

function get_current_branch() {
    git symbolic-ref --short HEAD
}

function push_current_branch() {
    local current_branch=$1
    git push origin $current_branch
}

function get_remote_url() {
    git config --get remote.origin.url
}

function set_upstream_if_not_exists() {
    local current_branch=$1
    local remote_url=$2

    if [ -z "$(git config --get remote.origin.upstream)" ]; then
        echo "No remote origin upstream found. Setting it now."
        git remote add upstream $remote_url
        git fetch upstream
        git branch --set-upstream-to=upstream/$current_branch $current_branch
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
    local current_branch=$(get_current_branch)
    push_current_branch $current_branch

    local remote_url=$(get_remote_url)

    if [ -z "$remote_url" ]; then
        echo "Error: No remote URL found. Please set up a remote repo on Github and try again."
        exit 1
    fi

    set_upstream_if_not_exists $current_branch $remote_url

    local user_and_repo=$(get_user_and_repo $remote_url)
    open_pull_request $user_and_repo $current_branch
}

main
