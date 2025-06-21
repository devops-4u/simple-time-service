
FROM python:3.12-slim

RUN useradd -m appuser

WORKDIR /app

COPY app.py requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
