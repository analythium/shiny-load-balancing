# Scaling Shiny Apps for Python and R

> We had high hopes for Heroku, as they have a documented option for session affinity. However, for reasons we don’t yet understand, the test application consistently fails to pass. We’ll update this page as we find out more. - [Shiny for Python docs](https://shiny.rstudio.com/py/docs/deploy.html#heroku)

**Shiny for R and Python** can be [deployed](https://shiny.rstudio.com/py/docs/deploy.html) in _conventional ways_, using RStudio Connect, Shiny Server Open Source, and Shinyapps.io.

When it comes to _alternative options_, the [docs](https://shiny.rstudio.com/py/docs/deploy.html#other-hosting-options) tell you to:

- have support for _WebSockets_, and
- use _sticky_ load balancing.

The following options support WebSockets, so let's see how well they can load balance among multiple app processes:

- [Heroku](./01-heroku.md)
- [DigitalOcean App Platform](./02-do-app-platform.md)
- [Fly.io](./03-fly.md)
- [Docker Compose](./04-docker-compose.md)

Deploying with Docker is straightforward, and everything works fine as long as the number of replicas is 1. Increasing the number of replicas is trickier, but not impossible:

| Hosting option  | Scaling instances  | Multiple regions  |
|---|---|---|
| [Heroku](./01-heroku.md)  | ✅  | ❌  |
| [DigitalOcean App Platform](./02-do-app-platform.md)  | ❌  | ❌  |
| [Fly.io](./03-fly.md)  | ❌  | ✅  |
| [Docker Compose](./04-docker-compose.md)  | ✅  | ❌  |


This repository contains supporting material ofr the following blog posts on the _Hosting Data Apps_ ([hosting.analythium.io](https://hosting.analythium.io/)) website:

- [Containerizing Shiny for Python Applications](https://hosting.analythium.io/)

## Testing sticky sessions

We build a Python and an R version of a test application to test how load balancing works. We use this [Shiny for Python test application](https://github.com/rstudio/py-shiny/blob/7ba8f90a44ee25f41aa8c258eceeba6807e0017a/examples/load_balance/app.py).

### Py-Shiny app

The [test application](https://github.com/rstudio/py-shiny/blob/7ba8f90a44ee25f41aa8c258eceeba6807e0017a/examples/load_balance/app.py) is build following the [usual Docker workflow for Shiny for Python](./00-py-shiny-docker.md).

We use the `Dockerfile.lb` and the app in the [`load-balancing`](load-balancing) folder containing the `app.py` and `requirements.txt` files.

Build, test run the image, and push to Docker Hub:

```shell
# build
# docker build -f Dockerfile.lb -t analythium/python-shiny-lb:0.1 .
docker buildx build --platform=linux/amd64 -f Dockerfile.lb -t analythium/python-shiny-lb:0.1 .

# run: open http://127.0.0.1:8080
docker run -p 8080:8080 analythium/python-shiny-lb:0.1

# push
docker push analythium/python-shiny-lb:0.1
```

> If you are running your container behind a TLS Termination Proxy (load balancer) like Nginx or Caddy, add the option `--proxy-headers`, this will tell Uvicorn to trust the headers sent by that proxy telling it that the application is running behind HTTPS, etc. - [FastAPI docs](https://fastapi.tiangolo.com/deployment/docker/)

### Shinylive

[Shinylive](https://shiny.rstudio.com/py/docs/shinylive.html) is an experimental feature (Shiny + WebAssembly) that allows applications to run entirely in a web browser, without the need for a separate server running Python.

We use the load balancing test application and build some static assets based on the `Dockerfile-lb-live` file:

```bash
# build
# docker build -f Dockerfile.lb-live -t analythium/python-shiny-live-lb:0.1 .
docker buildx build --platform=linux/amd64  -f Dockerfile.lb-live -t analythium/python-shiny-live-lb:0.1 .

# run: open http://127.0.0.1:8080
docker run -p 8080:8080 analythium/python-shiny-live-lb:0.1

# push
docker push analythium/python-shiny-live-lb:0.1
```

The [`docs`](docs) folder contains the exported Shinylive site with the static HTML, which is also deployed to GitHub Pages:
<https://hub.analythium.io/shiny-load-balancing>.

### R-Shiny app

The R version is a port of the Python app.

```shell
# build
# docker build -f Dockerfile.lb-r -t analythium/r-shiny-lb:0.1 .
docker buildx build --platform=linux/amd64 -f Dockerfile.lb-r -t analythium/r-shiny-lb:0.1 .

# run: open http://127.0.0.1:8080
docker run -p 8080:8080 analythium/r-shiny-lb:0.1

# push
docker push analythium/r-shiny-lb:0.1
```

## License

[MIT](LICENSE) 2022 (c) [Analythium Solutions Inc.](https://analythium.io)
