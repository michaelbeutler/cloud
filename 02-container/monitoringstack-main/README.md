# Monitoringstack for Cloud

This stack represents a straight forward monitoring solution based on prometheus and grafana.
Containers as well as infrastructure is directly monitored and stored.

## Components

The monitoring solution bases on:

- [Grafana](https://grafana.com/): Dashboards of monitoring data
- [Prometheus](https://prometheus.io/): Monitoring-Timedatabase, pulling different sources
- [Node Exporter](https://github.com/prometheus/node_exporter): Node Exporter collects data from the "hardware" itself
- [cAdvisor](https://github.com/google/cadvisor): cAdvisor collects information about containers

## Grafana Configuration

Grafana represents the graphical user interface including templating for dashboards.
To setup a login, the input must be defined as folder whereas the folder `grafana` must be mounted into the container.

Login is possible via:
User: admin
Password: foobar

## Prometheus Configuration

Prometheus represents the core of our monitoring solution.
Configured by a single file, it scrapes different targets and stores its values into an own time-based databases.
The monitoring data itself is provided with the help of different exporters.
The scraping of the different exporters is defined in the file `prometheus/prometheus.yml`.

The exporters are accessible via the following ports
- Prometheus: http://IP:9090
- Node Exporter: http://IP:9100
- cAdvisor: http://IP:8080
- Nginx-Exporter: http://IP:9113

Please note, that you might need to open security groups if you want to access to metrics directly e.g. for debugging purposes.

# Docker-Compose

All components / containers are defined in the file `docker-compose.yml`.

It needs 2 Volumes for persisting data, both are declared in the section `volumes` :

- Storage of the metrics of prometheus itself
- Configuration of grafana

In the `networks`-section, there are two networks:

- front-tier: this network is for external access
- back-tier: this network is for accesses of prometheus to the exporters.

All services are build up the same way:

- There are `Volumes` given, in which the container can store and access data.
- There is a `Command` given, to start the container, with some parameter.
- `Ports` provide access to fixed defined ports only. Normally they would not have been exposed but the external access supports debugging purposes.
- `Networks` defines the network, the container belongs to.
