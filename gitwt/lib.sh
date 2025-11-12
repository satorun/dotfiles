#!/usr/bin/env bash
# Git worktree management library
# Common utility functions for gitwt commands

# Get Git repository root directory
# Returns the absolute path to the repository root, or exits with error
gitwt_get_repo_root() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$repo_root" ]; then
        echo "Error: Not in a Git repository" >&2
        exit 1
    fi
    echo "$repo_root"
}

# Get repository name from the repository root
# Takes repository root as argument
gitwt_get_repo_name() {
    local repo_root="$1"
    if [ -z "$repo_root" ]; then
        repo_root=$(gitwt_get_repo_root)
    fi
    basename "$repo_root"
}

# Get worktree base directory
# Returns ../_wt/<repo_name>/ as absolute path
gitwt_get_wt_base() {
    local repo_root
    local repo_name
    local wt_base
    
    repo_root=$(gitwt_get_repo_root)
    repo_name=$(gitwt_get_repo_name "$repo_root")
    wt_base="$(dirname "$repo_root")/_wt/$repo_name"
    
    # Convert to absolute path
    if [[ "$wt_base" != /* ]]; then
        wt_base="$(cd "$(dirname "$repo_root")" && pwd)/_wt/$repo_name"
    fi
    
    echo "$wt_base"
}

# Sanitize branch name: replace / with __
# Example: feature/login-form -> feature__login-form
gitwt_sanitize_branch() {
    local branch="$1"
    if [ -z "$branch" ]; then
        echo "Error: Branch name is required" >&2
        exit 1
    fi
    echo "$branch" | sed 's|/|__|g'
}

# Get default startpoint for branch creation
# Returns origin/HEAD if available, otherwise tries main, then master
gitwt_get_default_startpoint() {
    local startpoint
    
    # Try origin/HEAD first
    if git rev-parse --verify origin/HEAD >/dev/null 2>&1; then
        startpoint="origin/HEAD"
    # Try main branch
    elif git rev-parse --verify origin/main >/dev/null 2>&1; then
        startpoint="origin/main"
    # Try master branch
    elif git rev-parse --verify origin/master >/dev/null 2>&1; then
        startpoint="origin/master"
    # Try local main
    elif git rev-parse --verify main >/dev/null 2>&1; then
        startpoint="main"
    # Try local master
    elif git rev-parse --verify master >/dev/null 2>&1; then
        startpoint="master"
    else
        echo "Error: Could not determine default startpoint" >&2
        exit 1
    fi
    
    echo "$startpoint"
}

# Check if branch exists (local or remote)
# Returns 0 if exists, 1 if not
gitwt_branch_exists() {
    local branch="$1"
    if [ -z "$branch" ]; then
        return 1
    fi
    
    # Check local branches
    if git show-ref --verify --quiet refs/heads/"$branch" 2>/dev/null; then
        return 0
    fi
    
    # Check remote branches
    if git show-ref --verify --quiet refs/remotes/origin/"$branch" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

# Get worktree path for a branch
# Takes branch name as argument
gitwt_get_wt_path() {
    local branch="$1"
    local wt_base
    local sanitized_branch
    
    if [ -z "$branch" ]; then
        echo "Error: Branch name is required" >&2
        exit 1
    fi
    
    wt_base=$(gitwt_get_wt_base)
    sanitized_branch=$(gitwt_sanitize_branch "$branch")
    
    echo "$wt_base/$sanitized_branch"
}

