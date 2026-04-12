# monitoring role

This role will deploy [Prometheus](https://prometheus.io/) & [Grafana](https://grafana.com/) stack using docker compose and official images. Also this role will auto-import grafana dashboard defined in `files/grafana-dashboards`

## Requirements

- `docker` is required

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`).

## Docker compose

- `docker_compose_monitoring_network` name of the network which will be created by docker-compose. By default `monitoring`
- `docker_compose_path` path where all of generated files by role will be placed. Eg `docker-compose.yml`, prometheus & grafana configs. By default `/opt/monitoring`
- `docker_compose_project_name` self-explanatory. Name for docker compose project. By default `monitoring`

## Prometheus

- `prometheus_image` self-explanatory. Prometheus docker image. By default `prom/prometheus`
- `prometheus_version` self-explanatory. Prometheus image tag. By default `v3.11.1`
- `prometheus_port` self-explanatory. Prometheus docker port. By default `9090`
- `prometheus_retention_time` configures prometheus data retension, eg how long prometheus time series will be kept on disk. By default `15d`
- `prometheus_storage_path` configures directory for prometheus storage. Keep in mind that inside container user is non-root and we need to explicitly chown `prometheus_storage_path` directory to 65534:65534 (FYI role does it for you). By default "/opt/prometheus"
- `prometheus_config_path` where to mount prometheus config file inside container. By default "/etc/prometheus"
- `prometheus_scrape_interval` how often prometheus will scrape metrics from itself and `additional_scrape_targets: []`. By default `10s`
- `additional_scrape_targets: []` configuration for prometheus scrape targets. Refer to `Example Playbook` section for examples. By default `[]`

## Grafana

- `grafana_image` self-explanatory. Grafana docker image. By default `grafana/grafana`
- `grafana_version` self-explanatory. Grafana image tag. By default `13.1.0-24243827787`
- `grafana_port` self-explanatory. Grafana port. By default `3000`
- `grafana_admin_user` self-explanatory. Grafana default admin user. By default `admin`
- `grafana_admin_password` self-explanatory. Grafana default admin user password. By default `admin`
- `grafana_storage_path` self-explanatory. Grafana storage path. By default `/opt/grafana`
- `grafana_provisioning_path` used to auto-provision dashboards and datasources. By default `/etc/grafana/provisioning`

## Dependencies

None.

## Example Playbook

Your playbook could look like this:

```yaml
- hosts: localhost
  become: true
  roles:
    - role: monitoring
  vars:
    grafana_admin_password: "cool_pass"

    additional_scrape_targets:
      - job_name: "node_exporter"
        scrape_interval: "5s"
        static_configs:
          - targets:
              - "my-host-ip-address:9100"
            labels:
              env: "production"
```
