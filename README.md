Monitoring Legacy Java Applications with Prometheus
---------------------------------------------------

Demo for my [FOSDEM 2018 presentation](https://fosdem.org/2018/schedule/event/monitoring_legacy_java_applications_with_prometheus/). Source is on [github.com/fstab/fosdem-2018](https://github.com/fstab/fosdem-2018), the Docker image is on [hub.docker.com/r/fstab/fosdem-2018](https://hub.docker.com/r/fstab/fosdem-2018/). Run as follows:

```bash
docker run --rm -p 8080:8080 -p 9999:9999 -p 9144:9144 -p 9115:9115 -p 1234:1234 -p 9300:9300 -t -i fstab/fosdem-2018
```
