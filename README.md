[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Docker Pulls](https://img.shields.io/docker/pulls/cthiel42/unity2promgo.svg?maxAge=604800)](https://hub.docker.com/r/cthiel42/unity2promgo/)

# unity2promgo
Prometheus Exporter for DellEMC Unity

Unity2Prom is a tool written in Go for exporting usage and performance metrics from Dell EMC Unity storage arrays to prometheus.

For RestAPI connectivity to the different Unity arrays [gounity by Equelin](https://github.com/equelin/gounity.git) is used.

## Configuration
### Configure the Exporter
Before starting the exporter it is required to update *config.json* with values specific to your environment:
```json
{
  "exporter": {
    "port":     8080,
    "interval": 60,
    "pools": true,
    "storage_resources": true,
    "metrics": ["sp_cifs_global_basic_writeBytesRate", "sp_cifs_smb1_usage_currentConnections","sp_net_device_pktsInRate","sp_net_device_pktsOut"]
  },
  "unitys": [
    {
      "ip": "192.168.2.190",
      "port": "",
      "user": "monitor",
      "password": "Monitor123!"
    }
  ]
}
```
*Unitys** is a list of all arrays for which data will be collected.
For the user it is sufficient to be a *Operator* User with read-only access.

**Exporter** conifgures the exporter and specifies the data that will be collected.
**!!!The interval in which metrics are collected should match the Prometheus scraping interval!!!**
Metrics can be added by adding the metric's *prom_path* to the metrics array.
Possible metrics and their description can be found in *unity_metrics.json*:

```json
  {
    "id": 10170,
    "name": "Read_Hit_Only Miss requests",
    "path": "sp.*.blockCache.flu.*.readHitOnlyMiss",
    "prom_path": "sp_blockCache_flu_readHitOnlyMiss",
    "type": 3,
    "description": "Number of Read_Hit_Only Miss requests",
    "isHistoricalAvailable": false,
    "isRealtimeAvailable": true,
    "unitDisplayString": "requests"
  },
```

### Configure Prometheus Scrape Job

In order to configure Prometheus to scrape the newly added metric it is requried to add another scrape_config entriy to the 
promehteus configuration file:
```yaml
scrape_configs:
- job_name: unity2go  
  scrape_interval: 60s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets:
    - <unity.fqdn|ip_adress>:9090    
```

## Installation
After installing go and cloning this repositroy it is required to install the following go dependencies:
- github.com/equelin/gounity
- github.com/prometheus/client_golang/prometheus
- github.com/prometheus/client_golang/prometheus/promhttp

This can be done using go *get -u <dependency_name>*

*Start the collector*
In the project base directory run
**go build**
**go run main.go utils.go unitycollector.go**

## Docker
Ensure that the configuration file you have is up-to-date and accurate with the metrics you want collected, the destination of your Unity array, and the credentials to connect to the array. Then you will be able to build the image.

Build the image with the following command
```
docker build -t unity2promgo --network=host .
```
Run the container with the following command
```
docker run -d \
        --name unity2promgo \
        --restart=always \
        --net=host \
        unity2promgo
```

An alternative way to run the container would be to pull the image from dockerhub with the following command
```
docker pull cthiel42/unity2promgo
```
and then mount your configuration file to the container in your docker run command similar to below
```
docker run -d \
        --name unity2promgo \
        --restart=always 
        --net=host \ 
        -v /Path/to/config.json:/opt/unityexporter/config.json:ro \ 
        cthiel42/unity2promgo
```

