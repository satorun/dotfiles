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

# Validate branch name
# Checks for empty, ".", "..", and control characters
gitwt_validate_branch_name() {
    local branch="$1"
    
    # Empty string check
    if [ -z "$branch" ]; then
        echo "Error: Branch name cannot be empty" >&2
        exit 1
    fi
    
    # "." and ".." check
    if [ "$branch" = "." ] || [ "$branch" = ".." ]; then
        echo "Error: Invalid branch name: '$branch' (cannot be '.' or '..')" >&2
        exit 1
    fi
    
    # Control characters check
    if [[ "$branch" =~ [[:cntrl:]] ]]; then
        echo "Error: Branch name contains control characters: '$branch'" >&2
        exit 1
    fi
}

# Sanitize branch name: replace / with __
# Example: feature/login-form -> feature__login-form
gitwt_sanitize_branch() {
    local branch="$1"
    if [ -z "$branch" ]; then
        echo "Error: Branch name is required" >&2
        exit 1
    fi
    # Validate before sanitizing
    gitwt_validate_branch_name "$branch"
    echo "${branch//\//__}"
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

# Check if worktree exists (registered in Git)
# Returns 0 if exists, 1 if not
gitwt_worktree_exists() {
    local wt_path="$1"
    if [ -z "$wt_path" ]; then
        return 1
    fi
    # Convert to absolute path for comparison
    local abs_path
    if [[ "$wt_path" == /* ]]; then
        # Already absolute path
        abs_path="$wt_path"
    else
        # Convert to absolute path
        if [ -d "$wt_path" ]; then
            abs_path="$(cd "$wt_path" && pwd)" 2>/dev/null || return 1
        else
            # Path doesn't exist yet, try to resolve parent directory
            local parent_dir="$(dirname "$wt_path")"
            local basename_part="$(basename "$wt_path")"
            if [ -d "$parent_dir" ]; then
                abs_path="$(cd "$parent_dir" && pwd)/$basename_part" 2>/dev/null || return 1
            else
                # Can't resolve, use as-is
                abs_path="$wt_path"
            fi
        fi
    fi
    git worktree list --porcelain 2>/dev/null | grep -q "^worktree $abs_path$"
}

# Check if verbose mode is enabled
# Returns 0 if verbose, 1 if not
# Default: verbose is enabled (set GITWT_VERBOSE=0 to disable)
gitwt_is_verbose() {
    local verbose="${GITWT_VERBOSE:-1}"
    [ "$verbose" != "0" ] && [ "$verbose" != "false" ]
}

# Execute git command with optional verbose output
# Usage: gitwt_git <git-command> [args...]
gitwt_git() {
    if gitwt_is_verbose; then
        echo "> git $*" >&2
    fi
    git "$@"
}
