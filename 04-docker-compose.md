Deploy to a VM.

```bash
docker-compose -f compose-repl.yml up -d

## follow the logs
docker-compose logs -f

docker-compose down --remove-orphans
```

The Docker Compose YAML file uses [anchors and extensions](https://www.howtogeek.com/devops/how-to-simplify-docker-compose-files-with-yaml-anchors-and-extensions/) because we deploy the same image multiple times so that we can load balance between the replicas. We do it this way, because the standard load balancing for scaling services is round robin, that is not sticky.

We use [Caddy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#load-balancing) for load balancing.

Try `lb_policy random` (default) to see the test fail. `lb_policy ip_hash` will succeed:

```bash
docker-compose up -d
```
