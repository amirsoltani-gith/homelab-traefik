#!/usr/bin/env bash

set -Eeuo pipefail

log() {
  printf '[database-init] %s\n' "$*"
}

wait_for_mariadb() {
  log "Waiting for MariaDB..."

  until mariadb \
    --host="${MARIADB_HOST}" \
    --user=root \
    --password="${MARIADB_ROOT_PASSWORD}" \
    --execute="SELECT 1;" >/dev/null 2>&1
  do
    sleep 2
  done

  log "MariaDB is ready."
}

create_database() {
  log "Creating database if it does not exist..."

  mariadb \
    --host="${MARIADB_HOST}" \
    --user=root \
    --password="${MARIADB_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS \`${NEXTCLOUD_DB_NAME}\`
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
SQL
}

create_user() {
  log "Creating user if it does not exist..."

  mariadb \
    --host="${MARIADB_HOST}" \
    --user=root \
    --password="${MARIADB_ROOT_PASSWORD}" <<SQL
CREATE USER IF NOT EXISTS '${NEXTCLOUD_DB_USER}'@'%'
IDENTIFIED BY '${NEXTCLOUD_DB_PASSWORD}';
SQL
}

grant_permissions() {
  log "Granting privileges..."

  mariadb \
    --host="${MARIADB_HOST}" \
    --user=root \
    --password="${MARIADB_ROOT_PASSWORD}" <<SQL
GRANT ALL PRIVILEGES
ON \`${NEXTCLOUD_DB_NAME}\`.*
TO '${NEXTCLOUD_DB_USER}'@'%';

FLUSH PRIVILEGES;
SQL
}

main() {
  wait_for_mariadb
  create_database
  create_user
  grant_permissions

  log "Database initialization completed."
}

main "$@"
