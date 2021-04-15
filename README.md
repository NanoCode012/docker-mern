# Docker MERN

This repo aims to create a one-stop script which would allow the setup of a MERN stack via multiple containers reliably.

# Requirements

- docker (with external network created)
- docker-compose
- wget

# Setup

```bash
$ wget https://raw.githubusercontent.com/NanoCode012/docker-mern/main/setup-server.sh -O setup-server.sh
$ chmod +x setup-server.sh
$ ./setup-server.sh
```

Note: Ignore `Git repo not initialized Error: Command failed: git --version` when creating base react files

# Usage

## Production

```bash
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

Add `-f docker-compose.ssl.yml` for SSL setup

## Development

```bash
$ docker-compose up -d --build
```

# Configuration

- For more docker-configuration, consider creating a new compose file with the changes and adding it via `-f` option

# Contribution

PRs are **greatly** appreciated, but please open an Issue first to discuss.

Questions? Open an Issue.
