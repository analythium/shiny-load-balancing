FROM python:3.9

RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /home/app
RUN chown app:app -R /home/app

COPY basic/requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt

COPY basic .

USER app
EXPOSE 8080

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
