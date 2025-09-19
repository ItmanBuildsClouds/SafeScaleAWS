FROM python:3.11

WORKDIR /app
RUN chown -R 1000:1000 /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV DUMMY_REBUILD=1

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]