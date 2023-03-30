#!/bin/bash

current_branch=$(git symbolic-ref --short HEAD)

git push origin $current_branch

remote_url=$(git config --get remote.origin.url)

if [ -z "$remote_url" ]; then
    echo "Error: No remote URL found. Please set up a remote repo on Github and try again."
    exit 1
fi

upstream_url=$(git config --get remote.upstream.url)

if [ -z "$upstream_url" ]; then
    echo "No remote upstream found. Setting it now."
    git remote add upstream $remote_url
    git fetch upstream
    git branch --set-upstream-to=upstream/$current_branch $current_branch
fi

user_and_repo=$(echo $remote_url | sed -E 's/.*github.com[:\/]//g' | sed 's/\.git$//g')

pr_url="https://github.com/$user_and_repo/compare/main...$current_branch?expand=1"

open $pr_url
