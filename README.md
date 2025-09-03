# CI/CD Pipeline with GitHub Actions, Terraform, EKS, and Helm
---

## 🌐 Step 0: Provision AWS Infrastructure with Terraform

Before setting up the CI/CD pipeline, I provisioned the AWS resources using Terraform (in a separate repository: [EKS-hello-again](https://github.com/mostafafawzy/EKS-hello-again)).

The Terraform repo creates:

- A VPC with:
  - 2 public subnets
  - 2 private subnets
- An Amazon EKS Cluster
- A Managed Node Group with **8 instances** t3.micro

It also creates IAM roles for:

- The EKS Cluster  
- The Node Group  

This ensures EKS cluster and networking are ready for the GitHub Actions pipeline.

---

## 🚀 Step 1: Create Dockerfile

The `Dockerfile` uses a Python base image (`python:3.9-slim`):

- Installs dependencies from `requirements.txt`
- Copies the Python application code into the container
- Exposes port **5000**
- Runs the app with:

```dockerfile
CMD ["python", "app.py"]

---

## ⚙️ Step 2: Create GitHub Workflow

Inside `.github/workflows/ci.yml`, define a workflow triggered on **pushes to the main branch**.  

Set environment variables for:

- ECR repository name  
- AWS region  
- EKS cluster name  

---

## 📂 Step 3: Checkout Code & Set Image Tag

- Use `actions/checkout` to pull the repo code.  
- Generate an `IMAGE_TAG` based on the current **timestamp** and save it to the GitHub Actions environment.  

---

## 🔑 Step 4: Configure AWS Credentials

Store AWS credentials in **GitHub Secrets**:

- `AWS_ACCESS_KEY_ID`  
- `AWS_SECRET_ACCESS_KEY`  

Use `aws-actions/configure-aws-credentials` to authenticate with AWS for both **ECR** and **EKS** access.  

---

## 🐳 Step 5: Login to Amazon ECR

Use `aws-actions/amazon-ecr-login` to authenticate with your **ECR registry**.  

---

## 🏗️ Step 6: Build and Push Docker Image

- Build the Docker image using the created Dockerfile.  
- Tag the image with the **timestamp-based tag**.  
- Push the image to **Amazon ECR**.  

---

## 📦 Step 7: Checkout Helm Chart for Application

In the GitHub workflow, a step is added to checkout the Helm chart repository : https://github.com/mostafafawzy/EKS-hello-again 

The Helm chart includes:

- **Deployment** using the Docker image from ECR  
- **Service** exposing the application internally  
- **Ingress resource** with nginx as ingressclass:
  - Routes `/users` → `/users`
  - Routes `/products` → `/products`

The ingress will use the **ELB DNS name** provided by the **NGINX ingress controller**.  

---

## 🚢 Step 8: Deploy Application with Helm

Deploy the application into the **EKS cluster**:

```bash
helm upgrade --install python-app ./helm-chart \
  --namespace default \
  --set image.repository=<ECR_Repo> \
  --set image.tag=<timestamp_tag>

## 🌐 Step 9: Install NGINX Ingress Controller

Install the **NGINX ingress controller** into the EKS cluster (creates an AWS LoadBalancer automatically):

helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer

the created ingress resources will be using the DNS name of the LB created for the ingress controller

## 📊 Step 10: Install Prometheus & Grafana for Cluster Monitoring

used helm chart to deploy Prometheus/Grafana Stack and exposed the Grafana UI by creating an ingress resource for Grafana
imported some Grafana Dashboards to monitor the performance of the EKS cluster
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: monitoring
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: monitoring-grafana
                port:
                  number: 80


