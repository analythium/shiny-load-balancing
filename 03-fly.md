# Fly.io

- [Back to README](./README.md)
- [Heroku](./01-heroku.md)
- [DigitalOcean App Platform](./02-do-app-platform.md)
- Fly.io
- [Docker Compose](./04-docker-compose.md)

Install [`flyctl`](https://fly.io/docs/hands-on/install-flyctl/), then log in:

```bash
# log in
flyctl auth login
```

Pick the Python or R version of the app here:

```bash
# prepare the launch (pick the Python or R version)
export IMAGE="analythium/python-shiny-lb:0.1"
# export IMAGE="analythium/r-shiny-lb:0.1"
flyctl launch --image $IMAGE
```

The app is not yet deployed, this is what you have to do:

```bash
# deploy is selected not to deploy
flyctl deploy

# print status
flyctl status
```

## Scaling on Fly.io

### Scale instance count in a single region

```bash
flyctl scale show

flyctl scale count 2
```

The 2 instances are based in the same region that you chose (see `flyctl regions list`).

Going to the app URL, we can see _Status: Failure!_

Destroy the app with `flyctl destroy <app_name>` before we go on to avoid any caching related issues.

### Increase number of regions

According to [this thread](https://community.fly.io/t/session-affinity-sticky-sessions/638) we can place instances in different regions to make sure traffic is only going to the closest instance.

Add a few more [regions](https://fly.io/docs/reference/regions/) and increase the scale count to 3.

> When you bump up your scale count, we’ll place your app in different regions (based on your region pool). If there are three regions in the pool and the count is set to six, there will be two app instances in each region. - [Fly.io docs](https://fly.io/docs/reference/scaling/#count-scaling)

So launch the same app again as above with `flyctl launch --image analythium/python-shiny-lb:0.1`. Then:

```bash
flyctl regions add ord cdg
flyctl scale count 3

# this will list instances and regions
flyctl status
```

Going to the app URL, soon you will see _Status: Test complete_.

Destroy the app with `flyctl destroy <app_name>`.

This might still fail if you increase instance count within the regions. You should also check if the instances were assigned into different regions, otherwise sticky session might not work as advertized.

## Resources

- <https://community.fly.io/t/session-affinity-sticky-sessions/638>
- <https://github.com/fly-apps/nginx-cluster>
- <https://hosting.analythium.io/auto-scaling-shiny-apps-in-multiple-regions-with-fly-io/#scaling>
