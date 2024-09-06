#!/bin/bash

# Exit on error, unset variables, or errors in a pipeline
set -euo pipefail

# Check if required command 'doctl' is available
command -v doctl >/dev/null 2>&1 || { echo >&2 "doctl is required but it's not installed. Aborting."; exit 1; }

# Function to list repositories
list_repositories() {
    doctl registry repository list-v2 --format Name | tail -n +2 | awk '{print $1}'
}

# Function to filter repositories based on include and exclude patterns
filter_repositories() {
    local repositories="$1"unset x
    local include="$2"
    local exclude="$3"

    if [[ -n "$include" ]]; then
        repositories=$(echo "$repositories" | grep -E "$include")
    fi

    if [[ -n "$exclude" ]]; then
        repositories=$(echo "$repositories" | grep -Ev "$exclude")
    fi

    echo "$repositories"
}

# Function to list and filter tags
filter_tags() {
    local repository="$1"
    local skip_size="$2"
    local include="$3"
    local exclude="$4"

    local tags
    tags=$(doctl registry repository list-tags "$repository" --format Tag,UpdatedAt | tail -n +2 | awk '{print $2, $3, $0}' | sort -k1r -k2r | cut -d' ' -f3 | tail -n +"$((skip_size+1))")

    if [[ -n "$include" ]]; then
        tags=$(echo "$tags" | grep -E "$include")
    fi

    if [[ -n "$exclude" ]]; then
        tags=$(echo "$tags" | grep -Ev "$exclude")
    fi

    echo "$tags"
}

# Function to delete tags from a repository
delete_tags() {
    local repository="$1"
    local tags="$2"

    if [[ -n "$tags" ]]; then
        doctl registry repository delete-tag "$repository" $tags --force
        echo "Deleted tags from $repository: $tags"
    else
        echo "No tags to delete for $repository."
    fi
}

# Function to perform garbage collection
perform_garbage_collection() {
    doctl registry garbage-collection start --include-untagged-manifests --force
    echo "Garbage collection started."
}

# Check if a variable is zero or a positive integer
is_zero_or_positive_integer() {
    local value="$1"
    [[ "$value" =~ ^[0-9]+$ ]]
}

# Main script echoic
main() {
    local reps_to_include="${1:-}"
    local reps_to_exclude="${2:-}"
    local tags_to_skip_size="${3:-10}"
    local tags_to_include="${4:-}"
    local tags_to_exclude="${5:-}"
    local perform_gc="${6:-false}"

    # Check if tags_to_skip_size is zero or a positive integer
    if ! is_zero_or_positive_integer "$tags_to_skip_size"; then
        echo "Error: tags_to_skip_size must be zero or a positive integer. Provided value: $tags_to_skip_size"
        exit 1
    fi

    # Fetch and filter the repositories list
    repositories=$(list_repositories)
    repositories=$(filter_repositories "$repositories" "$reps_to_include" "$reps_to_exclude")

    # Process each repository
    for repository in $repositories; do
        tags=$(filter_tags "$repository" "$tags_to_skip_size" "$tags_to_include" "$tags_to_exclude")
        tags=$(echo "$tags" | tr '\n' ' ')
        delete_tags "$repository" "$tags"
    done

    # Perform garbage collection if requested
    if [[ "$perform_gc" == "true" ]]; then
        perform_garbage_collection
    fi
}

# Run the main function
main "$@"