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

    docker exec -u app -w /data/web/magento2 "$container_name" bin/magento setup:config:set \
        --db-host="localhost" \
        --db-name="$db_name" \
        --db-user="$db_user" \
        --db-password="$db_password" \
        --backend-frontname="admin" \
        --session-save="files" \
        --no-interaction

    set_env_php_init_params "$container_name"
}

# --magento-init-params doesn't reliably get written into env.php by
# setup:config:set on some Magento versions, so set MAGE_MODE and the
# install date directly on the generated env.php instead.
set_env_php_init_params() {
    local container_name=$1

    log_info "Setting MAGE_MODE and install date in env.php..."

    local current_date
    current_date=$(date "+%a, %d %b %Y %H:%M:%S %z")

    docker exec -u app -w /data/web/magento2 "$container_name" sed -i \
        "0,/return \[/s//return [\n    'MAGE_MODE' => 'developer',\n    'install' => ['date' => '${current_date}'],/" \
        app/etc/env.php
}

run_magento_setup() {
    local container_name=$1
    log_info "Running Magento setup commands..."
    
    docker exec -u app -w /data/web/magento2 "$container_name" bin/magento setup:upgrade
}

configure_magento_base_urls() {
    local container_name=$1
    local domain=$2
    
    log_info "Configuring Magento base URLs..."
    
    docker exec -u app -w /data/web/magento2 "$container_name" bin/magento config:set web/unsecure/base_url "http://${domain}/"
    docker exec -u app -w /data/web/magento2 "$container_name" bin/magento config:set web/secure/base_url "http://${domain}/"
}
