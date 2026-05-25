#!/usr/bin/env bash

set -euo pipefail

ensure_project_dir() {
    local project_dir=$1
    if [[ ! -d "$project_dir" ]]; then
        log_info "Creating project directory: $project_dir"
        mkdir -p "$project_dir"
    fi
}

clone_repo() {
    local repo_url=$1
    local target_dir=$2
    
    if [[ -d "${target_dir}/.git" ]]; then
        log_warn "Repository already exists in $target_dir. Skipping clone."
    else
        log_info "Cloning repository $repo_url..."
        git clone "$repo_url" "$target_dir"
    fi
}

extract_media() {
    local archive=$1
    local target_dir=$2 # This should be magento_root/pub/media
    
    if [[ ! -f "$archive" ]]; then
        log_warn "Media archive not found: $archive. Skipping media extraction."
        return
    fi
    
    log_info "Extracting media archive $archive..."
    mkdir -p "$target_dir"
    tar -xzf "$archive" -C "$target_dir" --strip-components=1 2>/dev/null || tar -xzf "$archive" -C "$target_dir"
}

create_container_symlink() {
    local container_name=$1
    local source=$2
    local target=$3
    
    log_info "Creating symlink inside container: $target -> $source"
    docker exec "$container_name" ln -sf "$source" "$target"
}
