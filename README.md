# Docker MERN

This repo aims to create a one-stop script which would allow the setup of a MERN stack via multiple containers reliably.

# Requirements

- docker (with external network created)
- docker-compose
- wget

Tested working with Ubuntu 20.04

# Setup

```bash
$ wget https://raw.githubusercontent.com/NanoCode012/docker-mern/main/setup-server.sh -O setup-server.sh
$ chmod +x setup-server.sh
$ ./setup-server.sh
```

Note: Ignore `Git repo not initialized Error: Command failed: git --version` when creating base react files

### Optional arguments:

- `barebone` run with default options and without creating react and node files

# Usage

## Production

```bash
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.http.yml up -d --build
```

Add `-f docker-compose.ssl.yml` for SSL setup and remove `-f docker-compose.http.yml`.

_TIP_: Make a bash file that runs the above for you. This functionality will be added later.

## Development

```bash
$ docker-compose up -d --build
```

# Configuration

- For more docker-configuration, consider creating a new compose file with the changes and adding it via `-f` option

# Script Development/Test

Pass in environment variable `BRANCH=the_branch_name` before calling script, so that the script knows where to `wget` the files.

# Contribution

PRs are **greatly** appreciated, but please open an Issue first to discuss.

Questions? Open an Issue.
