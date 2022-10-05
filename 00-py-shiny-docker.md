# Containerizing Shiny for Python

We follow the [Get started](https://shiny.rstudio.com/py/docs/get-started.html) guide. The following commands generate the app file that we will use (see inside the [`basic`](basic) folder):

```shell
pip install shiny
shiny create basic
shiny run --reload basic/app.py
```

You can read more about [FastAPI deployment](https://fastapi.tiangolo.com/deployment/docker/).

We will use the [app with plot](https://shinylive.io/py/examples/#app-with-plot) example that is in the [`basic/app.py`](basic/app.py) file with the [requirements](basic/requirements.txt).

Here is how the `Dockerfile` looks like:

```Dockerfile
FROM python:3.9

# Add user an change working directory and user
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /home/app
RUN chown app:app -R /home/app
USER app

# Install requirements
COPY basic/requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Copy the app
COPY basic .

# Run app on port 8080
EXPOSE 8080
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

## Shinylive

[Shinylive](https://shiny.rstudio.com/py/docs/shinylive.html) is an experimental feature (Shiny + WebAssembly) that allows applications to run entirely in a web browser, without the need for a separate server running Python.

Let's create the simplest Shiny app again inside the `live` folder:

```bash
shiny create live
```

Add a `live/requirements.txt` file with the following contents (Shinylive is installed on its own, no need to include):

```
shiny
```

The dockerfile follows the pattern from the [static R Markdown deployment](https://hosting.analythium.io/containerizing-interactive-r-markdown-documents/#runtime-static):

- install requirements + Shinylive
- copy the app
- build Shinylive assets in the `site` folder
- copy the `site` folder into a minimal image alongside the [OpenFaaS watchdog](https://github.com/openfaas/of-watchdog#4-static-modestatic) and serve

```Dockerfile
FROM python:3.9 AS builder
WORKDIR /root
COPY live/requirements.txt .
RUN pip install shinylive
RUN pip install --no-cache-dir --upgrade -r requirements.txt
COPY live app
RUN shinylive export app site

FROM ghcr.io/openfaas/of-watchdog:0.9.6 AS watchdog

FROM alpine:latest
RUN mkdir /app
COPY --from=builder /root/site /app
COPY --from=watchdog /fwatchdog .
ENV mode="static"
ENV static_path="/app"
HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1
CMD ["./fwatchdog"]
```

Build, test, push:

```bash
# build
# docker build -f Dockerfile.live -t analythium/python-shiny-live:0.1 .
docker buildx build --platform=linux/amd64  -f Dockerfile.live -t analythium/python-shiny-live:0.1 .

# run: open http://127.0.0.1:8080
docker run -p 8080:8080 analythium/python-shiny-live:0.1

# push
docker push analythium/python-shiny-live:0.1
```
