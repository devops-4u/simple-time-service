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
🏗️ Task 1 – Dockerize Python Application
 
## 📦 Application Structure

### ➤✅  `app.py`

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
```
 sudo apt-get update && sudo apt-get install docker.io -y
```

### ➤`✅Dockerfile`

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
git remote add origin https://github.com/devops-4u/simple-time-service.git
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
****************************************************************************************************************************

🏗️ Task 2 – Terraform: Create Infrastructure

## 📦 Components Provisioned

- **VPC** with public and private subnets across 2 availability zones
- **NAT Gateway** for outbound internet access from private subnets
- **EKS Cluster** in private subnets
- **Managed Node Group** in private subnets
- **IAM roles** for cluster and nodes

### ➤✅ `main.tf`
```
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.43.0, < 6.0.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["${var.aws_region}a", "${var.aws_region}b"]

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_nat_gateway   = true        
  single_nat_gateway   = true  
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      min_capacity     = 1
      max_capacity     = 3

      instance_types = ["t3.small"]
      subnet_ids     = module.vpc.private_subnets
    }
  }
}
```
### ➤✅ `outputs.tf`

```
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
```
### ➤✅ `terraform.tfars`

```
aws_region    = "ap-south-1"
cluster_name  = "simpletimeservice-eks"
```

### ➤✅ `variables.tf`

```
variable "aws_region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  default = "simpletimeservice-eks"
}
```

### 1️⃣ Initialize Terraform

🚀 Deploy Infrastructure
```
terraform init
terraform plan
terraform apply -auto-approve
```
📌 Notes
- EKS cluster and worker nodes are deployed in private subnets.
- Bastion host must be deployed separately in the public subnet to access the private cluster.
- Use aws eks update-kubeconfig from a Bastion EC2 instance for kubectl access.

🚢 Deploy Flask App to EKS 

### ➤ ✅`deployment.yaml`
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpletimeservice
spec:
  replicas: 2
  selector:
    matchLabels:
      app: simpletimeservice
  template:
    metadata:
      labels:
        app: simpletimeservice
    spec:
      containers:
      - name: simpletimeservice
        image: jatin7011/simpletimeservice:latest
        ports:
        - containerPort: 5000
```

### ➤✅ `service.yaml`
```
apiVersion: v1
kind: Service
metadata:
  name: simpletimeservice
spec:
  selector:
    app: simpletimeservice
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer

```
🧪 Apply and Verify 
```
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deployment, svc
```

🧪  To forward the port in background

```
nohup kubectl port-forward deployment/simpletimeservice 5000:5000 > /dev/null 2>&1 &
curl http://localhost:5000
```










