# docker role

This role will install [Docker](https://www.docker.com/) & docker compose

## Requirements

- systemd for service management

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`).

## APT repository setup

- `docker_installation_candidate` which edition of docker engine to install. Available options: "ce" (Community Edition) / "ee" (Enterprise Edition). By default `ce`
- `docker_automatic_repo_setup` automatically add and configure docker APT repositories, can be toggled off by setting this value to `false`. By default `true`
- `docker_download_url` self-explanatory. By default `https://download.docker.com/linux`
- `docker_apt_release_channel` self-explanatory. APT release channel. By default `stable`

## Docker & Docker compose installation options

- `docker_pkgs_state` self-explanatory. Docker packages state. By default `present`
- `docker_pkgs` list of docker packages which will be installed. Refer to `defaults/main.yml` for more details

- `docker_install_docker_compose` should role install docker compose automatically. By default `true`
- `docker_compose_pkg_state` self-explanatory. Docker compose package state. By default `present`
- `docker_compose_pkg` self-explanatory. By default `docker-compose-plugin`

## systemd

- `docker_enable_service_at_boot` should role enable docker service at boot. By default `true`
- `docker_service_state` docker systemd service state. By default `started`
- `docker_service_enabled` is docker systemd service should be enabled. By default `true`

## Users

- `docker_group_name` self-explanatory. Docker group name. By default `docker`
- `docker_users: []` list of users which will be appended to docker group. By default `[]`

## Dependencies

None.
