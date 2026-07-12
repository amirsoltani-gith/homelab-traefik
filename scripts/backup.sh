#!/usr/bin/env bash

set -Eeuo pipefail

#
# Backup Utility
#
# Production-inspired Homelab Infrastructure
#
# Current features:
#   - Backup workspace initialization
#   - Metadata collection
#   - Logging
#
# Planned:
#   - MariaDB logical backups
#   - Docker volume backups
#   - Retention cleanup
#   - Restore support
#

########################################
# Configuration
########################################

readonly SCRIPT_VERSION="0.1.0"

readonly PROJECT_NAME="homelab-traefik"

readonly BACKUP_ROOT="./backups"
readonly TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")"
readonly BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

# TODO:
# Remove backups older than RETENTION_DAYS
readonly RETENTION_DAYS=7

########################################
# Create backup directory
########################################

mkdir -p "${BACKUP_DIR}"

readonly LOG_FILE="${BACKUP_DIR}/backup.log"

exec > >(tee -a "${LOG_FILE}")
exec 2>&1

########################################
# Logging
########################################

log() {
    printf "[%s] %s\n" "$(date +"%F %T")" "$*"
}

########################################
# Dependency Checks
########################################

check_dependencies() {

    local dependencies=(
        docker
        git
    )

    for dependency in "${dependencies[@]}"; do
        if ! command -v "${dependency}" >/dev/null 2>&1; then
            log "ERROR: Required dependency '${dependency}' is not installed."
            exit 1
        fi
    done

}

########################################
# Metadata
########################################

collect_metadata() {

    cat > "${BACKUP_DIR}/metadata.txt" <<EOF
Project: ${PROJECT_NAME}
Version: ${SCRIPT_VERSION}

Date: $(date)

Hostname: $(hostname)

Kernel:
$(uname -r)

Architecture:
$(uname -m)

OS:
$(source /etc/os-release && echo "${PRETTY_NAME}")

Docker:
$(docker --version)

Docker Compose:
$(docker compose version)

Git Commit:
$(git rev-parse --short HEAD)

Git Branch:
$(git branch --show-current)
EOF

}

########################################
# MariaDB Backup
########################################

backup_mariadb() {

    local backup_file="${BACKUP_DIR}/database/mariadb.sql"

    mkdir -p "${BACKUP_DIR}/database"

    log "Creating MariaDB backup..."

    docker compose exec -T mariadb \
        mariadb-dump \
        -u"${MARIADB_USER}" \
        -p"${MARIADB_PASSWORD}" \
        --databases \
        "${MARIADB_DATABASE}" \
        > "${backup_file}"

    log "MariaDB backup created: ${backup_file}"

}

########################################
# Docker Volumes Backup
########################################

backup_volumes() {

    local backup_path="${BACKUP_DIR}/volumes"

    mkdir -p "${backup_path}"

    local volumes=(
        wordpress_data
        mariadb_data
        redis_data
        nextcloud_data
        uptimekuma_data
    )

    for volume in "${volumes[@]}"; do

        log "Backing up volume: ${volume}"

        docker run --rm \
            -v "${PROJECT_NAME}_${volume}:/volume:ro" \
            -v "${backup_path}:/backup" \
            alpine:latest \
            tar -czf "/backup/${volume}.tar.gz" -C /volume .

    done

    log "Docker volumes backup completed."

}

########################################
# Retention Cleanup
########################################

cleanup_old_backups() {

    log "Removing backups older than ${RETENTION_DAYS} days..."

    local removed=false

    while IFS= read -r backup; do

        log "Removing: ${backup}"

        rm -rf "${backup}"

        removed=true

    done < <(
        find "${BACKUP_ROOT}" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -mtime +"${RETENTION_DAYS}"
    )

    if [[ "${removed}" == false ]]; then
        log "No expired backups found."
    else
        log "Retention cleanup completed."
    fi

}

########################################
# Main
########################################

main() {

    check_dependencies

    log "Starting backup..."

    collect_metadata

    log "Metadata created."

    backup_mariadb
    backup_volumes
    cleanup_old_backups

    log "Backup initialization completed."

}

set -a
source .env
set +a

main "$@"
