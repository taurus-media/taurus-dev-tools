#!/usr/bin/env bash

set -euo pipefail

run_composer_install() {
    local container_name=$1
    log_info "Running composer install..."
    docker exec -u app -w /data/web/magento2 "$container_name" composer install --no-interaction
}

generate_env_php() {
    local project_path=$1
    local db_name=$2
    local db_user=$3
    local db_password=$4
    local base_url=$5
    
    log_info "Generating app/etc/env.php..."
    
    local template_file="${TAURUS_ROOT}/templates/env.php.template"
    local target_file="${project_path}/app/etc/env.php"
    
    mkdir -p "$(dirname "$target_file")"
    
    # Generate random keys for Magento
    local crypt_key
    crypt_key=$(LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)
    local cache_prefix
    cache_prefix=$(LC_ALL=C tr -dc 'a-z' < /dev/urandom | fold -w 3 | head -n 1)_
    
    sed -e "s/{{DB_NAME}}/${db_name}/g" \
        -e "s/{{DB_USER}}/${db_user}/g" \
        -e "s/{{DB_PASSWORD}}/${db_password}/g" \
        -e "s/{{BASE_URL}}/${base_url}/g" \
        -e "s/{{CRYPT_KEY}}/${crypt_key}/g" \
        -e "s/{{CACHE_PREFIX}}/${cache_prefix}/g" \
        -e "s/{{MAGE_ENV}}/developer/g" \
        "$template_file" > "$target_file"
}

run_magento_setup() {
    local container_name=$1
    log_info "Running Magento setup commands..."
    
    docker exec -u app -w /data/web/magento2 "$container_name" bin/magento setup:upgrade
    docker exec -u app -w /data/web/magento2 "$container_name" bin/magento setup:static-content:deploy -f -j 4
}

configure_magento_base_urls() {
    local container_name=$1
    local domain=$2
    
    log_info "Configuring Magento base URLs..."
    
    docker exec -u app -w /data/web/magento2 "$container_name" bin/magento config:set web/unsecure/base_url "http://${domain}/"
    docker exec -u app -w /data/web/magento2 "$container_name" bin/magento config:set web/secure/base_url "http://${domain}/"
}
