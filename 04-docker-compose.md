# Docker compose

This setup has 2 replicas of the app:

```bash
docker-compose up -d

## follow the logs
docker-compose logs -f

docker-compose down --remove-orphans
```

The setup fails because the standard load balancing for scaling services is round robin, that is not sticky.

We can add sticky sessions using [Caddy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#load-balancing) for load balancing.

The `docker-compose-lb.yml` file uses [anchors and extensions](https://www.howtogeek.com/devops/how-to-simplify-docker-compose-files-with-yaml-anchors-and-extensions/) because we deploy the same image multiple times so that we can load balance between the replicas.


Try `lb_policy random` (default) to see the test fail. `lb_policy ip_hash` will succeed:

```bash
docker-compose -f docker-compose-lb.yml up -d
```
