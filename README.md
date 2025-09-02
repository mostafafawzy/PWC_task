# CI/CD Pipeline with GitHub Actions, EKS, and Helm

---

## ⚙️ Step 2: Create GitHub Workflow

Inside `.github/workflows/ci-cd.yml`, define a workflow triggered on **pushes to the main branch**.  

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

In the GitHub workflow, add a step to checkout the Helm chart repository (e.g., `mostafafawzy/PWC_task_Helm`).  

The Helm chart includes:

- **Deployment** using the Docker image from ECR  
- **Service** exposing the application internally  
- **Ingress resource**:
  - Routes `/users` → `/users`
  - Routes `/products` → `/products`

The ingress will use the **ELB DNS name** provided by the **NGINX ingress controller**.  

---

## 🚢 Step 8: Deploy Application with Helm

Deploy the application into the **EKS cluster**:

```bash
helm upgrade --install python-app ./helm-chart \
  --namespace default \
  --set image.repository=<your_ecr_repo_url> \
  --set image.tag=<timestamp_tag>
