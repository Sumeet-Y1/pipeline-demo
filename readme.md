# AWS-CI-CD-Pipeline

Automated CI/CD pipeline that builds, containerizes, and deploys a Spring Boot application to AWS EC2 on every `git push` using GitHub Actions, Docker, Terraform, and Amazon ECR.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Application | Spring Boot (Java 21) |
| Containerization | Docker |
| Image Registry | AWS ECR |
| Cloud Server | AWS EC2 (t3.micro) |
| Infrastructure as Code | Terraform |
| CI/CD Automation | GitHub Actions |
| OS | Ubuntu (Linux) |

---

## Pipeline Architecture

```
Developer pushes code to GitHub (main branch)
              ↓
    GitHub Actions triggered
              ↓
     Checkout code from repo
              ↓
       Setup JDK 21 (Temurin)
              ↓
   Maven build → generates .jar file
              ↓
  Configure AWS credentials (GitHub Secrets)
              ↓
       Login to AWS ECR
              ↓
  Docker build → tag → push image to ECR
              ↓
    SSH into AWS EC2 (appleboy/ssh-action)
              ↓
  EC2: Pull latest image from ECR (via IAM Role)
              ↓
  EC2: Stop old container → Start new container
              ↓
   App live at http://<EC2_PUBLIC_IP>:8080 ✅
```

---

## Infrastructure (Terraform)

All AWS infrastructure is provisioned as code using Terraform:

- **AWS ECR** — private Docker image registry
- **AWS EC2** (t3.micro) — server to run the container
- **IAM Role + Instance Profile** — allows EC2 to pull from ECR securely (no hardcoded credentials)
- **Security Group** — opens port `22` (SSH) and `8080` (app)

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

---

## GitHub Secrets Required

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `AWS_REGION` | `ap-south-1` |
| `EC2_PUBLIC_IP` | EC2 public IP from `terraform output` |
| `EC2_SSH_KEY` | Full contents of `.pem` key file |
| `ECR_REPOSITORY_URL` | ECR repo URL from `terraform output` |

---

## Run Locally

```bash
# Clone the repo
git clone https://github.com/Sumeet-Y1/AWS-CI-CD-Pipeline.git
cd AWS-CI-CD-Pipeline

# Build the jar
mvn clean package -DskipTests

# Build Docker image
docker build -t aws-ci-cd-pipeline .

# Run container
docker run -p 8080:8080 aws-ci-cd-pipeline
```

Hit `http://localhost:8080/hello` — you should see:
```
Hello from Pipeline Demo!
```

---

## API Endpoint

| Method | Endpoint | Response |
|---|---|---|
| GET | `/hello` | `Hello from Pipeline Demo!` |

---

## Project Structure

```
AWS-CI-CD-Pipeline/
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actions CI/CD workflow
├── src/
│   └── main/java/com/devops/pipeline_demo/
│       ├── PipelineDemoApplication.java
│       └── HelloController.java
├── terraform/
│   ├── main.tf              # AWS infrastructure
│   ├── variables.tf
│   └── outputs.tf
├── Dockerfile
└── pom.xml
```

---

## Key Learnings

- How to provision cloud infrastructure with **Terraform**
- How to build and push Docker images to **AWS ECR**
- How to use **IAM Roles** for secure EC2-to-ECR access (no hardcoded credentials)
- How to automate deployments with **GitHub Actions** YAML workflows
- Debugging SSH auth, AMI OS mismatches, and package manager differences (apt vs yum)