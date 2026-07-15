# Production-Like Homelab Infrastructure

![Docker](https://img.shields.io/badge/Docker-29.x-2496ED?logo=docker&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-v3-24A1C1?logo=traefikproxy&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white)
![License](https://img.shields.io/github/license/amirsoltani-gith/homelab-traefik)
![Status](https://img.shields.io/badge/status-active-success)

# A production-like homelab infrastructure built with Docker Compose and Traefik to practice Linux system administration, containerized infrastructure, networking, and self-hosted services.

> This project follows production-inspired design and operational practices for learning, experimentation, and portfolio purposes. It is not intended to be deployed in production environments.

---

# Overview

This repository documents the process of building and maintaining a self-hosted infrastructure using Docker Compose.

The project focuses on:

- Linux system administration
- Docker-based deployments
- Reverse proxy configuration with Traefik
- Service isolation using Docker networks
- Infrastructure documentation
- Practical DevOps learning through hands-on projects

---

# Current Stack

- Ubuntu Server 24.04 LTS
- Docker Engine 29.x
- Docker Compose v2
- Traefik v3
- MariaDB 11
- Redis 8
- WordPress (PHP 8.3)
- phpMyAdmin
- Nextcloud 31
- Uptime Kuma 2

---

# Current Services

| Service | Status |
|----------|--------|
| Traefik | ✅ |
| WordPress | ✅ |
| MariaDB | ✅ |
| Redis | ✅ |
| phpMyAdmin | ✅ |
| Nextcloud | ✅ |
| Uptime Kuma | ✅ |
| Element | Planned |

---

# Repository Structure

```text
.
├── .env.example
├── .gitignore
├── docker/
│   └── database-init/
│       └── init.sh
├── docker-compose.yml
├── LICENSE
├── README.md
├── docs/
│   ├── architecture.md
│   └── networking.md
├── images/
├── scripts/
│   ├── backup.sh
│   └── restore.sh
└── traefik/
    ├── certs/
    ├── dynamic/
    │   ├── middlewares/
    │   ├── routers/
    │   └── tls/
    └── traefik.yml

```

---

# Architecture

```

                  Internet
                    │
                    ▼
             Traefik Reverse Proxy
                    │
     ┌────────┬───────────┬────────────┬─────────────┐
     │        │           │            │
 WordPress Nextcloud phpMyAdmin Uptime Kuma
     │        │           │
     └────────┴───────────┘
             │
          MariaDB
             │
          (Nextcloud)
             │
           Redis

```

---

# Features

- Docker Compose based deployment
- Reverse proxy with Traefik v3
- Internal and public Docker networks
- Persistent Docker volumes
- Environment variable support
- Modular Traefik configuration
- Infrastructure documentation
- Git Flow based development workflow
- Nextcloud deployment
- Database administration with phpMyAdmin
- Uptime monitoring
- Backup and restore automation
- Backup validation
- Docker volume backup
- MariaDB backup and restore

---

# Networking

The infrastructure uses two Docker networks.

| Network | Purpose |
|----------|---------|
| proxy | Public services exposed through Traefik |
| internal | Internal communication between containers |

Only services that must be reachable through Traefik are connected to the `proxy` network.

---

# Documentation

Project documentation is located inside the `docs/` directory.

Current documentation includes:

- Architecture
- Networking
- CHANGELOG

Additional documentation will be added as the project grows.

---

# Requirements

Before running this project, ensure the following software is installed:

- Ubuntu Server 24.04 LTS (recommended)
- Docker Engine 29.x or newer
- Docker Compose v2
- Git

---

# Quick Start

Clone the repository.

```bash
git clone git@github.com:amirsoltani-gith/homelab-traefik.git

cd homelab-traefik
```

Create the environment file.

```bash
cp .env.example .env
```

Start the infrastructure.

```bash
docker compose up -d
```

---

# Project Goals

This repository is used to practice:

- Linux administration
- Docker
- Networking
- Reverse proxies
- Infrastructure documentation
- Troubleshooting
- Git workflows

---

# Roadmap

## v0.1

- ✅ Traefik
- ✅ MariaDB
- ✅ Redis
- ✅ WordPress

## v0.2

- ✅ HTTPS
- ✅ Let's Encrypt
- ✅ Security headers
- Dashboard

## v0.3

- ✅ phpMyAdmin
- ✅ Nextcloud

## v0.4

- ✅ Uptime Kuma
- ✅ Monitoring

## v0.5

- ✅ Backup automation
- ✅ Restore automation
- Telegram notifications

## Future

- Telegram notifications
- GitHub Actions
- CI validation
- Container health checks
- Automated testing
- Automatic updates
- Disaster recovery documentation

---

# Development Workflow

```
feature/*
      │
      ▼
develop
      │
      ▼
main
      │
      ▼
Release
```

Git Flow is used to keep the repository organized and maintain a clean commit history.

---

# Project Status

Current version:

**v0.5.1**

This project is actively developed and new services will be added incrementally.

---

# License

This project is licensed under the MIT License.
