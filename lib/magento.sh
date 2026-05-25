#!/usr/bin/env bash

set -euo pipefail

run_composer_install() {
    local container_name=$1
    log_info "Running composer install..."
    docker exec -u app -w /data/web/magento2 "$container_name" composer install --no-interaction
}

generate_env_php() {
    local container_name=$1
    local db_name=$2
    local db_user=$3
    local db_password=$4
    local base_url=$5
    
    log_info "Generating app/etc/env.php using bin/magento setup:config:set..."
    
    local current_date
    current_date=$(date "+%a, %d %b %Y %H:%M:%S %z")
    
    docker exec -u app -w /data/web/magento2 "$container_name" bin/magento setup:config:set \
        --db-host="localhost" \
        --db-name="$db_name" \
        --db-user="$db_user" \
        --db-password="$db_password" \
        --backend-frontname="admin" \
        --session-save="files" \
        --magento-init-params="MAGE_MODE=developer&install[date]=${current_date}" \
        --no-interaction
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
