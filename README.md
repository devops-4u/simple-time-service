# simple-time-service
Participating  in Particle41 DevOps Team Challenge

# 🕒 SimpleTimeService

A minimalist Python Flask microservice that returns the current UTC timestamp and the IP address of the requester.

---

## 🔧 Tech Stack

- **Language**: Python (Flask)
- **Containerization**: Docker
- **Container Registry**: DockerHub (Public)
- **Source Control**: GitHub (Public)

---

## 📦 Application Structure

### ➤ `app.py`

```python
from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "ip": request.remote_addr,
        "Partcle41_Assessment": "Tiny App Development_SimpleTimeService"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

```
### Install Docker 

➤ sudo apt-get update && sudo apt-get install docker.io -y

### `Dockerfile`

```Dockerfile

FROM python:3.12-slim
RUN useradd -m appuser
WORKDIR /app
COPY app.py requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]

```
➤➤ Build & Run the Container
```
# Build Docker image
docker build -t simpletimeservice .

# Run the container
docker run -it -d -p 5000:5000 simpletimeservice:latest

# Check running containers
docker ps
```

## 🐳 Push to DockerHub

```bash
# Login to DockerHub
docker login

# Tag the image
docker tag simpletimeservice:latest jatin7011/simpletimeservice:latest

# Push the image
docker push jatin7011/simpletimeservice:latest
```

## 🛠️ GitHub - Push to Public Repository
```
git init
```

Create a public repository on GitHub with a name "simple-time-service"

Push your code:
```bash
git add .
git commit -m "Initial commit - SimpleTimeService"
git branch -M master
git remote add origin https://github.com/<your-username>/simple-time-service.git
git push -u origin master
```

➤➤➤➤ OUTPUT:

```json
{
  "timestamp": "2025-06-21T10:30:00Z",
  "ip": "127.0.0.1",
  "Partcle41_Assessment": "Tiny App Development_SimpleTimeService"
}
```
