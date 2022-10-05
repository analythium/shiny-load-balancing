# Containerizing Shiny for Python

We follow the [Get started](https://shiny.rstudio.com/py/docs/get-started.html) guide. The following commands generate the app file that we will use (see inside the [`basic`](basic) folder):

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
