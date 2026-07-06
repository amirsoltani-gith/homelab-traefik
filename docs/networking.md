# Networking

## Network Topology

The infrastructure is divided into two Docker networks.

### proxy

The public-facing network connected to Traefik.

Services connected:

- Traefik
- WordPress
- Nextcloud
- Uptime Kuma
- phpMyAdmin

---

### internal

The private backend network.

Services connected:

- WordPress
- Nextcloud
- MariaDB
- Redis
- phpMyAdmin

No database or cache service is exposed directly to the host.

---

## Design Goals

- Minimize exposed services
- Separate public and private traffic
- Improve security
- Keep networking simple and maintainable
