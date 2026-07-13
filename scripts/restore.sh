#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_VERSION="1.0.0"

BACKUP_PATH="${1:-}"

log() {
    printf "[%s] %s\n" "$(date +"%F %T")" "$*"
}

usage() {
    echo "Usage:"
    echo "  ./scripts/restore.sh <backup-directory>"
    exit 1
}

validate_backup() {

    [[ -n "${BACKUP_PATH}" ]] || usage

    [[ -d "${BACKUP_PATH}" ]] || {
        log "ERROR: Backup directory not found."
        exit 1
    }

    [[ -f "${BACKUP_PATH}/database/mariadb.sql" ]] || {
        log "ERROR: MariaDB backup not found."
        exit 1
    }

    [[ -s "${BACKUP_PATH}/database/mariadb.sql" ]] || {
        log "ERROR: MariaDB backup is empty."
        exit 1
    }

    [[ -d "${BACKUP_PATH}/volumes" ]] || {
        log "ERROR: Volumes directory not found."
        exit 1
    }

    for volume in \
    wordpress_data \
    mariadb_data \
    redis_data \
    nextcloud_data \
    uptimekuma_data
do
    [[ -f "${BACKUP_PATH}/volumes/${volume}.tar.gz" ]] || {
        log "ERROR: Missing volume backup: ${volume}.tar.gz"
        exit 1
    }
done

}

confirm_restore() {

    echo
    echo "WARNING!"
    echo "This operation will overwrite existing Docker volumes and MariaDB data."
    echo

    read -r -p "Type 'YES' to continue: " confirmation

    if [[ "${confirmation}" != "YES" ]]; then
        log "Restore cancelled."
        exit 0
    fi

}

stop_services() {

    log "Stopping Docker services..."

    docker compose down

    log "Docker services stopped."

}

########################################
# Restore Docker Volumes
########################################

restore_volumes() {

    local backup_path
    backup_path="$(realpath "${BACKUP_PATH}/volumes")"

    local volumes=(
        wordpress_data
        mariadb_data
        redis_data
        nextcloud_data
        uptimekuma_data
    )

    log "Restoring Docker volumes..."

    for volume in "${volumes[@]}"; do

        log "Restoring volume: ${volume}"

        docker volume create "${PROJECT_NAME}_${volume}" >/dev/null

        docker run --rm \
            -v "${PROJECT_NAME}_${volume}:/volume" \
            -v "${backup_path}:/backup:ro" \
            alpine:latest \
            sh -c "
                rm -rf /volume/* /volume/.[!.]* /volume/..?* 2>/dev/null || true
                tar -xzf /backup/${volume}.tar.gz -C /volume
            "

    done

    log "Docker volumes restored."

}

wait_for_mariadb() {

    log "Waiting for MariaDB..."

    local retries=30

    until docker compose exec -T mariadb mariadb-admin ping \
        -u"${MARIADB_USER}" \
        -p"${MARIADB_PASSWORD}" \
        --silent >/dev/null 2>&1
    do
        ((retries--))

        if [[ ${retries} -le 0 ]]; then
            log "ERROR: MariaDB did not become ready."
            exit 1
        fi

        sleep 2
    done

    log "MariaDB is ready."

}

restore_database() {

    log "Starting MariaDB..."

    docker compose up -d mariadb

    wait_for_mariadb

    log "Recreating database..."

    docker compose exec -T mariadb \
        mariadb \
        -u"${MARIADB_ROOT_USER:-root}" \
        -p"${MARIADB_ROOT_PASSWORD}" <<EOF
DROP DATABASE IF EXISTS \`${MARIADB_DATABASE}\`;
CREATE DATABASE \`${MARIADB_DATABASE}\`;
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    log "Restoring MariaDB database..."

    docker compose exec -T mariadb \
    mariadb \
    -u"${MARIADB_ROOT_USER:-root}" \
    -p"${MARIADB_ROOT_PASSWORD}" \
    "${MARIADB_DATABASE}" \
    < "${BACKUP_PATH}/database/mariadb.sql"

    log "MariaDB restored."

}

start_services() {

    log "Starting Docker services..."

    docker compose up -d

    log "Docker services started."

}

health_check() {

    log "Running health checks..."

    local retries=30

    while (( retries > 0 )); do

        local unhealthy=0

        while read -r container; do
            local status
            status="$(docker inspect \
                --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' \
                "$container")"

            case "$status" in
                running|healthy)
                    ;;
                *)
                    unhealthy=1
                    ;;
            esac

        done < <(docker compose ps -q)

        if [[ $unhealthy -eq 0 ]]; then
            log "All services are healthy."
            return
        fi

        sleep 2
        ((retries--))

    done

    log "ERROR: Health check failed."

    docker compose ps

    exit 1
}

main() {

    log "Restore Utility v${SCRIPT_VERSION}"

    validate_backup
    log "Backup validation completed."

    confirm_restore
    log "Restore confirmed."

    stop_services
    restore_volumes
    restore_database
    start_services
    health_check

    log "Restore completed successfully."
    log "Backup restored from: ${BACKUP_PATH}"

}

set -a
source .env
set +a

readonly PROJECT_NAME="${COMPOSE_PROJECT_NAME}"

main "$@"

