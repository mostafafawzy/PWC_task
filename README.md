🌐 Step 0: Provision AWS Infrastructure with Terraform

Before setting up the CI/CD pipeline, I provisioned the AWS resources using Terraform (in a separate repository : https://github.com/mostafafawzy/EKS-hello-again).

The Terraform repo creates VPC with:

2 public subnets

2 private subnets

and also creates an Amazon EKS Cluster and a Managed Node Group with 8 instances

Create IAM roles for:

The EKS Cluster

The Node Group

This ensures your cluster and networking are ready for the GitHub Actions pipeline.

🚀 Step 1: Create Dockerfile
the docker file created uses a Python base image (e.g., python:3.10-slim)

Installs dependencies from requirements.txt

Copies the Python application code into the container

Exposes port 5000

Runs the app using CMD ["python", "app.py"]

Step 2: Create GitHub Workflow

Inside .github/workflows/ci-cd.yml, I defined a workflow that triggers on pushes to the main branch.

Set environment variables for:

ECR repository name

AWS region

EKS cluster name

Step 3: Checkout Code & Set Image Tag

Used the actions/checkout step to pull the repo code.

Generate an IMAGE_TAG based on the current timestamp and save it to the GitHub Actions environment.

Step 4: Configure AWS Credentials

Used GitHub Secrets to store AWS credentials:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

Used the aws-actions/configure-aws-credentials action to authenticate with AWS for both ECR and EKS access.

Step 5: Login to Amazon ECR

Used the aws-actions/amazon-ecr-login action to authenticate with your ECR registry.

Step 6: Build and Push Docker Image

Build the Docker image using the created Dockerfile.

Tag the image with the timestamp-based tag.

Push the image to Amazon ECR.

Step 7: Checkout Helm Chart for Application

In the GitHub workflow, add a step to checkout the Helm chart repository (for example: mostafafawzy/PWC_task_Helm).

The Helm chart has:

Deployment using the Docker image pushed to ECR

Service exposing the application internally

Ingress resource that:

Routes /users → /users

Routes /products → /products

The ingress will use the ELB DNS name provided by the NGINX ingress controller.

Step 8: Deploy Application with Helm

Deployed the application into the EKS cluster with:

helm upgrade --install python-app ./helm-chart \
  --namespace default \
  --set image.repository=<your_ecr_repo_url> \
  --set image.tag=<timestamp_tag>

Step 9: Install NGINX Ingress Controller

Install the NGINX ingress controller into the EKS cluster (creates an AWS LoadBalancer automatically):

helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer


This will provision an AWS ELB and map all ingress resources inside the cluster to the ELB’s DNS name.

📊 Step 10: Install Prometheus & Grafana for Cluster Monitoring

To monitor the EKS cluster and workloads, installed Prometheus and Grafana using Helm.

Added the kube-prometheus-stack Helm repo:

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


Installed Prometheus & Grafana:

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
