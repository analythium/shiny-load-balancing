FROM python:3.9
COPY basic/requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt
WORKDIR app
COPY basic .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
