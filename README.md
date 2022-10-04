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

A minimal `Dockerfile` needs the following:

```Dockerfile
FROM python:3.9
COPY basic/requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt
WORKDIR app
COPY basic .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
```

But `pip` will warn against installing as a root user, so we do this instead:

```Dockerfile
FROM python:3.9

# Add user an change working directory
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /home/app
RUN chown app:app -R /home/app

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

## Deployment

### Docker Compose

Deploy to a VM.

The Docker Compose YAML file uses [anchors and extensions](https://www.howtogeek.com/devops/how-to-simplify-docker-compose-files-with-yaml-anchors-and-extensions/) because we deploy the same image multiple times so that we can load balance between the replicas. We do it this way, because the standard load balancing for scaling services is round robin, that is not sticky.

We use [Caddy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#load-balancing) for load balancing.

Try `lb_policy random` (default) to see the test fail. `lb_policy ip_hash` will succeed:

```bash
docker-compose up -d
```

### DigitalOcean App Platform

- In the Dashboard, go to Apps / Create App
- Under Resources: select Docker Hub and type in the repository name and tag, click Next
- Edit the Plan, e.g. 1 vCPU under Basic Plan for $5/mo
- No need to set environment variables for now
- Edit the info as needed, e.g. data region, app name, etc.
- You can review settings once more: if you click on the Web Service settings, you can override the Run Command, HTTP Port, and Request Route
- If all look good, click Create Resource and wait until deployment is complete, then follow the link and check you app

### Heroku

Install Git and the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) and log in using `heroku login`.

Then follow [this guide](https://devcenter.heroku.com/articles/git) to set up and deploy with Git:

```bash
# creat the app
heroku create -a python-shiny
# check that the heroku remote is added
git remote -v
```

Now we use the `heroku.yml` as our manifest to build the Docker image on Heroku:

```bash
# set the stack of your app to container:
heroku stack:set container
```

Check in your commits, then `git push heroku main`. This will build the image and deploy your app on Heroku.

Get the app URL from `heroku info`, then check the app.

## License

[MIT](LICENSE) 2022 (c) [Analythium Solutions Inc.](https://analythium.io)


```bash
docker-compose -f compose-repl.yml up -d

## follow the logs
docker-compose logs -f

docker-compose down --remove-orphans
```

```bash
docker build -f Dockerfile.hist -t analythium/python-shiny-hist:0.1 .

docker run -p 8080:8080 analythium/python-shiny-hist:0.1

# push
docker push analythium/python-shiny-lb:0.1

```