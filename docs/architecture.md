# Architecture

## Overview

This project demonstrates a production-inspired self-hosted infrastructure built with Docker Compose and Traefik.

The goal is to provide a clean, reusable, and well-documented home lab that reflects common deployment patterns used in small to medium-sized production environments.

---

## Objectives

- Deploy multiple services using Docker Compose
- Use Traefik as the central reverse proxy
- Secure services with HTTPS
- Isolate services using Docker networks
- Store persistent data using Docker volumes
- Keep configuration modular and maintainable

---

## High-Level Architecture

Internet
        │
        ▼
 DNS (A Records)
        │
        ▼
 Traefik Reverse Proxy
        │
 ┌──────┼─────────┬────────────┬────────────┐
 ▼      ▼         ▼            ▼
WordPress Nextcloud Uptime Kuma phpMyAdmin
   │         │
   ▼         ▼
MariaDB    Redis

---

## Core Components

| Component | Purpose |
|----------|---------|
| Traefik | Reverse proxy and HTTPS termination |
| WordPress | CMS application |
| Nextcloud | Self-hosted cloud platform |
| Uptime Kuma | Monitoring |
| phpMyAdmin | Database administration |
| MariaDB | Database server |
| Redis | Cache for Nextcloud |

---

## Design Principles

- Infrastructure as documentation
- Reproducible deployments
- Service isolation
- Minimal public exposure
- Easy maintenance
