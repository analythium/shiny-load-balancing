# Docker compose

- [Back to README](./README.md)
- [Heroku](./01-heroku.md)
- [DigitalOcean App Platform](./02-do-app-platform.md)
- [Fly.io](./03-fly.md)
- Docker Compose

## Using replicas

This setup has 2 replicas of the app:

```bash
export IMAGE="analythium/python-shiny-lb:0.1"
# export IMAGE="analythium/r-shiny-lb:0.1"

docker-compose up -d

## follow the logs
docker-compose logs -f

## shut down
docker-compose down --remove-orphans
```

The setup fails because the standard load balancing for scaling services is round robin, that is not sticky. 

The Caddy load balancing setting has no effect, because Docker is still adding its own load balancing behind Caddy.

## Manual replicas

We can add sticky sessions using [Caddy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#load-balancing) for load balancing.

The `docker-compose-lb.yml` file uses [anchors and extensions](https://www.howtogeek.com/devops/how-to-simplify-docker-compose-files-with-yaml-anchors-and-extensions/) because we deploy the same image multiple times so that we can load balance between the replicas.


Try `lb_policy random` (default) to see the test fail. `lb_policy ip_hash` will succeed:

```bash
export LB_POLICY="ip_hash"
# export LB_POLICY="random"

export IMAGE="analythium/python-shiny-lb:0.1"
# export IMAGE="analythium/r-shiny-lb:0.1"

docker-compose -f docker-compose-lb.yml up -d

## follow the logs
docker-compose logs -f

## shut down
docker-compose down --remove-orphans
```
