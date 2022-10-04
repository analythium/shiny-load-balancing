# Shiny for Python Apps with Docker

This repository contains supporting material ofr the following blog posts on the _Hosting Data Apps_ ([hosting.analythium.io](https://hosting.analythium.io/)) website:

- [Containerizing Shiny for Python Applications](https://hosting.analythium.io/)

We follow the [Get started](https://shiny.rstudio.com/py/docs/get-started.html) guide.

## Basic Py-Shiny App

The following commands generate the app file that we will use (see inside the [`basic`](basic) folder):

```shell
pip install shiny
shiny create app
shiny run --reload app/app.py
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

## Sticky sessions

We use this [test application](https://github.com/rstudio/py-shiny/blob/7ba8f90a44ee25f41aa8c258eceeba6807e0017a/examples/load_balance/app.py) to make sure that your deployment has sticky sessions configured.

The `Dockerfile.lb` is very similar but is based on the app in the [`load-balancing`](load-balancing) folder and the `app.py` and `requirements.txt` files.

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

## Deployment

Shiny for Python can be [deployed](https://shiny.rstudio.com/py/docs/deploy.html) in conventional ways, using RStudio Connect, Shiny Server Open Source, and Shinyapps.

When it comes to alternative options, the [docs](https://shiny.rstudio.com/py/docs/deploy.html#other-hosting-options) tell you to:

- have support for WebSockets, and
- use sticy load balancing.

This is where the [test application](https://github.com/rstudio/py-shiny/blob/7ba8f90a44ee25f41aa8c258eceeba6807e0017a/examples/load_balance/app.py) comes in.

> We had high hopes for Heroku, as they have a documented option for session affinity. However, for reasons we don’t yet understand, the test application consistently fails to pass. We’ll update this page as we find out more. - [Shiny for Python docs](https://shiny.rstudio.com/py/docs/deploy.html#heroku)

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

[Delete the app](https://help.heroku.com/LGKL6LTN/how-do-i-delete-destroy-a-heroku-application) from the dashboard or use `heroku apps:destroy --confirm=python-shiny` (this will remove the git remote as well).

### DigitalOcean App Platform

Using [`doctl`](https://docs.digitalocean.com/reference/doctl/):

You'll need to [authenticate](https://docs.digitalocean.com/reference/doctl/reference/auth/)) first, and possibly use a named context if you are using multiple accounts:

```bash
# simplest
doctl auth init

# or use a specific token for an account
export TOKEN=$(cat ~/.do/doctl-token)
doctl auth init -t $TOKEN

# or use a named context
doctl auth list
doctl auth switch --context <context_name>
```

```bash
# Validate app spec
doctl apps spec validate app.yml

# Create app
doctl apps create --spec app.yml
```

Use the app ID from the output of the deployment or from `doctl apps list` if you want to delete the app:

```bash
export ID=d53da7f9-7b23-48af-9f2f-5224210df12c
doctl apps delete $ID --force
```

Use the Dashboard:

- In the Dashboard, go to Apps / Create App
- Under Resources: select Docker Hub and type in the repository name and tag, click Next
- Edit the Plan, e.g. 1 vCPU under Basic Plan for $5/mo
- No need to set environment variables for now
- Edit the info as needed, e.g. data region, app name, etc.
- You can review settings once more: if you click on the Web Service settings, you can override the Run Command, HTTP Port, and Request Route
- If all look good, click Create Resource and wait until deployment is complete, then follow the link and check you app

## License

[MIT](LICENSE) 2022 (c) [Analythium Solutions Inc.](https://analythium.io)
