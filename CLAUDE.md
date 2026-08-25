# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A bash CLI (`taurus`) that automates local Magento 2 dev environment setup on macOS using Hypernode Docker images. Entry point: `bin/taurus`, which sources modules from `lib/`.

## Running / testing

No test suite or linter is configured. To try changes, run the CLI directly:

```bash
./bin/taurus init --project <name> --repo <git-url> --php 8.3 --db <dump.sql.gz> --media <media.tar.gz>
./bin/taurus help
```

`init` is destructive against local state (writes `/etc/hosts`, removes/recreates a Docker container, clones into `~/Projects/<project>.local`) — be careful re-running it.

## Architecture

`bin/taurus` is the command router; each subcommand (currently only `init` is implemented — `start/stop/restart/ssh/destroy` are stubs) calls functions sourced from `lib/*.sh`:

- `lib/utils.sh` — logging (`log_info`/`log_success`/`log_warn`/`log_error`) and `exit_with_error`
- `lib/config.sh` — resolves PHP version → Docker image via `config/php-images.conf`; reads DB password from container's `.my.cnf`
- `lib/filesystem.sh` — clones the project repo, extracts media archive, manages symlinks inside the container
- `lib/docker.sh` — runs the Hypernode container, builds a per-project custom image with the host's SSH pubkey baked in, configures vhosts
- `lib/hosts.sh` — appends `127.0.0.1 <project>.local` to `/etc/hosts` (sudo)
- `lib/ssh.sh` — locates the host's SSH public key
- `lib/database.sh` — waits for MySQL, creates the DB, imports a dump
- `lib/magento.sh` — runs `composer install`, `bin/magento setup:config:set/upgrade`, sets base URLs

`init` flow (in `cmd_init`, `bin/taurus`): clone repo → update hosts → build custom SSH-enabled image → run container (static ports 80/443/3306/22) → configure vhosts → create+import DB → extract media → composer install → generate `env.php` → symlink `pub` → `setup:upgrade` → set base URLs.

Adding PHP version support = add a line to `config/php-images.conf`.

Containers are named `<project>.local` and mount the project dir at `/data/web/magento2` inside the container (Hypernode's `app` user home is `/data/web`).
