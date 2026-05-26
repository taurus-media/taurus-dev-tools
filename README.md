# Taurus - Magento Local Environment Automation

Taurus is a CLI tool designed to automate the Magento 2 local setup workflow for macOS development teams using Hypernode Docker images.

## Features

- Automatic Magento 2 repository cloning.
- Hypernode Docker container management.
- Automatic `/etc/hosts` configuration.
- SSH access configuration for developers.
- Database and media import automation.
- Automated Magento environment configuration (`env.php`).
- Composer and Magento setup command execution.

## Requirements

- macOS
- Docker Desktop
- Git
- Sudo privileges (for `/etc/hosts` and symlink creation)

## Installation

To install Taurus, run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/taurus-media/taurus-dev-tools/master/install.sh | bash
```

This will:
1. Verify Docker and Git are installed.
2. Clone the repository to `~/.taurus-dev-tools`.
3. Create a symlink in `/usr/local/bin/taurus`.
4. Make the tool executable.

## Usage

### Initialize a new project

```bash
taurus init \
  --project ogm2 \
  --repo git@bitbucket.org:taurus_media/ohhg-m2.git \
  --php 8.3 \
  --db ~/Downloads/ogm2.sql.gz \
  --media ~/Downloads/ogm2_media.tar.gz
```

### Supported PHP Versions
- 8.2
- 8.3
- 8.4

Mappings are defined in `config/php-images.conf`.

### Commands Reference

- `taurus init`: Fully implemented. Initializes a new project.
- `taurus start`: (Stub) Start project containers.
- `taurus stop`: (Stub) Stop project containers.
- `taurus restart`: (Stub) Restart project containers.
- `taurus ssh`: (Stub) Access container via SSH.
- `taurus destroy`: (Stub) Remove project.

## Architecture Overview

- **`bin/taurus`**: Main entry point and command router.
- **`lib/`**: Modularized logic for Docker, Database, Magento, etc.
- **`config/`**: Configuration for PHP versions and Docker images.

## Project Conventions

- **Projects directory**: `~/Projects/`
- **Domain**: `<project>.local`
- **Metadata**: Stored in `~/Projects/<project>.local/.taurus.env`
- **Magento Root (Container)**: `/data/web/magento2`
- **Public Directory (Container)**: `/data/web/public` (Symlinked to `pub`)

## Troubleshooting

- **Sudo Prompt**: Taurus requires sudo to update `/etc/hosts` and install the CLI.
- **Docker Access**: Ensure Docker Desktop is running before using Taurus.
- **SSH Keys**: Taurus looks for `~/.ssh/id_rsa.pub` to configure container access.

## Future Roadmap

- [ ] Implement `taurus start/stop/restart`
- [ ] Implement `taurus destroy`
- [ ] Implement `taurus db-import`
- [ ] Implement `taurus pull-db` and `taurus pull-media`
- [ ] Implement `taurus logs`
