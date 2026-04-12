# iperf3-server role

## Requirements

- `iperf3` is required. The role will install it for you.
- Systemd for service management

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`).

- `iperf3_server_pkg` contains package which role needs to install. By default `iperf3`
- `iperf3_server_pkg_state` controls packages state from `iperf3_server_pkg`. Available values: `present`, `absent`. By default `present`
- `iperf3_server_options` contains arguments which will be passed for iperf server systemd unit. By default `--server`
- `iperf3_server_systemd_enabled` controls if systemd service for iperf3-server should be enabled. By default `true`
- `iperf3_server_systemd_state` iperf3 server systemd state. Accepted values: `reloaded`, `restarted`, `started`, `stopped`. By default `started`
- `iperf3_server_systemd_unit_file_location` location where role put iperf3-server systemd unit file. By default `/etc/systemd/system/iperf3-server.service`
- `iperf3_server_user` user for iperf systemd unit. By default `iperf`
- `iperf3_server_group` group for iperf systemd unit. By default `iperf`

## Dependencies

None.
