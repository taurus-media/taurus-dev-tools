# Taurus Dev Tools - Magento Local Environment Automation

Taurus Dev Tools is a CLI tool designed to automate the Magento 2 local setup workflow for macOS development teams using Hypernode Docker images.

## Features

- Automatic Magento 2 repository cloning.
- Hypernode Docker container management.
- Automatic `/etc/hosts` configuration.
- SSH access configuration for developers (host SSH public key baked into a per-project Docker image, plus a bundled Node.js runtime for asset builds).
- Database and media import automation.
- Automated Magento environment configuration (`env.php`, developer mode, install date).
- Composer install, `setup:upgrade`, cache enable, and reindex.
- Automatic Hyvä theme style builds (detected from `deploy-config.php`).
- Interactive prompts for any required option left off the command line.

## Requirements

- macOS
- Docker Desktop
- Git
- Sudo privileges (for `/etc/hosts` and symlink creation)

## Installation

To install Taurus Dev Tools, run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/taurus-media/taurus-dev-tools/master/install.sh | bash
```

This will:
1. Verify Docker and Git are installed.
2. Clone the repository to `~/.taurus-dev-tools`.
3. Create a symlink in `/usr/local/bin/taurus`.
4. Make the tool executable.

## Usage
### Setup a project locally

1. Download DB dump
2. Download media files archive (optional)
3. Init the project:
    ```bash
    taurus init
    ```

    You'll be prompted for each required parameter (project name, repo URL, DB dump path) as well as the optional ones. This is the normal way to run it.

    Alternatively, pass any parameters on the command line to skip their prompt:
    ```bash
    taurus init \
      --project your-project-name \
      --repo git@bitbucket.org:taurus_media/ohhg-m2.git \
      --php 8.3 \
      --db /path/to/db/dump.sql.gz \
      --media /path/to/media.tar.gz
    ```

    This is required for non-interactive use (e.g. CI) — `--project`, `--repo`, and `--db` must all be passed explicitly, since there's no prompt to fall back on. `--media` stays optional (skip it to leave `pub/media` empty), and `--php` still defaults to `8.3`.

    Available options for `init`:

    | Option | Required | Default | Description |
    |---|---|---|---|
    | `--project` | Yes | — | Project name, e.g. `ogm2` (site becomes `<project>.local`) |
    | `--repo` | Yes | — | Git repository URL to clone |
    | `--db` | Yes | — | Path to database dump (`.sql`, `.sql.gz`, or `.tar.gz`) |
    | `--media` | No | (skipped) | Path to media archive (`.tar.gz`), extracted into `pub/media` |
    | `--php` | No | `8.3` | PHP version — see [Supported PHP Versions](#supported-php-versions) |
    | `--node-version` | No | `24.19.0` | Node.js version installed into the container, used for Hyvä theme builds |

    Paths passed to `--db` and `--media` (or entered at the prompts) support a leading `~`.

Once the project is initialized and the container is running, the frontend will be available at [http://your-project-name.local/](http://your-project-name.local/).

You can also log in to the container via SSH:

```bash
ssh app@your-project-name.local
```

The SSH public key found on your host machine is automatically added to the container's `authorized_keys`, so there should be no password prompt.

### Supported PHP Versions
- 8.1
- 8.2
- 8.3
- 8.4

Mappings are defined in `config/php-images.conf`.

### Hyvä Theme Styles

If the project's `deploy-config.php` declares a `hyva_themes` list, `taurus init` runs `npm install` and `npm run build` in each theme's `web/tailwind` directory automatically, using the Node.js version bundled into the container. Projects without Hyvä (no `deploy-config.php`, or no `hyva_themes` entries) skip this step.

### Commands Reference

- `taurus init`: Fully implemented. Initializes a new project.
- `taurus start`: (Stub) Start project containers.
- `taurus stop`: (Stub) Stop project containers.
- `taurus restart`: (Stub) Restart project containers.
- `taurus ssh`: (Stub) Access container via SSH.
- `taurus destroy`: (Stub) Remove project.

## Troubleshooting

- **Sudo Prompt**: Taurus requires sudo to update `/etc/hosts` and install the CLI.
- **Docker Access**: Ensure Docker Desktop is running before using Taurus.
- **SSH Keys**: Taurus looks for your public key (e.g., `~/.ssh/id_ed25519.pub` or `~/.ssh/id_rsa.pub`) to configure container access. The key is "baked" into a project-specific Docker image for persistence.

## Future Roadmap

- [ ] Implement `taurus start/stop/restart`
- [ ] Implement `taurus destroy`
- [ ] Implement `taurus db-import`
- [ ] Implement `taurus pull-db` and `taurus pull-media`
- [ ] Implement `taurus logs`
