# monitoring role

This role will deploy [node_exporter](https://github.com/prometheus/node_exporter)

## Requirements

- `systemd` is required for launching node exporter

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`).

## node_exporter

- `node_exporter_version` self-explanatory. node_exporter version. By default `1.11.1`
- `node_exporter_repo` self-explanatory. node_exporter github project. By default `prometheus/node_exporter`
- `node_exporter_arch` self-explanatory. OS architecture. By default `amd64`
- `node_exporter_binary_path` defines where node_exporter binary will be placed after unarchiving. Also this variable will be used to check current node_exporter version. By default `/usr/local/bin/node_exporter`
- `node_exporter_web_listen_address` self-explanatory. node_exporter listen address. By default `0.0.0.0:9100`
- `node_exporter_web_telemetry_path` self-explanatory. node_exporter /metrics path. By default `/metrics`
- `node_exporter_web_disable_exporter_metrics` disable all metrics from node_exporter instance. By default `false`
- `node_exporter_log_level: "info"`, `node_exporter_log_format: "logfmt"` node_exporter log level and log format
- `node_exporter_enabled_collectors[]` enabled collectors for node_exporter. By default `["system"]`
- `node_exporter_disabled_collectors[]` disable node_exporter collectors. By default `[]`

## System stuff

- `node_exporter_system_group` group for node_exporter. By default `node-exporter`
- `node_exporter_system_user` user for node_exporter. By default copies value from `node_exporter_system_group`

- `node_exporter_systemd_service_state` controls state of node_exporter systemd service. By default `started`
- `node_exporter_systemd_service_enabled` controls if node_exporter systemd service will be enabled by default. By default `true`

## Dependencies

None.
