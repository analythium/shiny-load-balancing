# Shiny for Python Apps with Docker

- [Shiny for Python: Get started](https://shiny.rstudio.com/py/docs/get-started.html)
- [Shiny for Python: Deployment](https://shiny.rstudio.com/py/docs/deploy.html)
- [FastAPI deployment](https://fastapi.tiangolo.com/deployment/docker/)

## Basic Py-Shiny App

The following commands generate the app file that we will use (see inside the [`basic`](basic) folder):

```shell
pip install shiny
shiny create app
shiny run --reload app/app.py
```

Our `Dockerfile` has the following:

```Dockerfile
FROM python:3.9
COPY basic/requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt
WORKDIR app
COPY basic .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
```

Build, test run the image, and push to Docker Hub:

```shell
# build
# docker build -t analythium/python-shiny:0.1 .
docker buildx build --platform=linux/amd64 -t analythium/python-shiny:0.1 .

# run: open http://127.0.0.1:8080
docker run -p 8080:8080 analythium/python-shiny:0.1

# push
docker push analythium/python-shiny:0.1
```

## Sticky sessions

We use this [test application](https://github.com/rstudio/py-shiny/blob/7ba8f90a44ee25f41aa8c258eceeba6807e0017a/examples/load_balance/app.py) to make sure that your deployment has sticky sessions configured.

The `Dockerfile.lb` is very similar but is based on the app in the `load-balancing` folder.



Anchors and extensions: https://www.howtogeek.com/devops/how-to-simplify-docker-compose-files-with-yaml-anchors-and-extensions/

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

If you are running your container behind a TLS Termination Proxy (load balancer) like Nginx or Caddy, add the option `--proxy-headers`, this will tell Uvicorn to trust the headers sent by that proxy telling it that the application is running behind HTTPS, etc.

## Docker Compose

Docker Compose anchors and extensions: https://www.howtogeek.com/devops/how-to-simplify-docker-compose-files-with-yaml-anchors-and-extensions/

Caddy LB: https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#load-balancing

Try `lb_policy random` (default) to see the test fail. `lb_policy ip_hash` will succeed:

```bash
docker-compose up -d
```
