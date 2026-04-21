#  Go Lambda CI/CD Pipeline with Jenkins & Terraform

##  Overview

This project implements an automated CI/CD pipeline for deploying Go-based AWS Lambda functions using **Jenkins** and **Terraform**.

Whenever changes are merged into the `main` branch, the pipeline automatically:

* Builds all Go Lambda functions
* Packages them into deployment-ready artifacts
* Provisions/updates infrastructure via Terraform
* Deploys each function to AWS Lambda

Each subdirectory inside the `lambda/` folder is treated as an independent Lambda function.

---

##  Architecture

```
GitHub (main branch)
        │
        ▼
     Jenkins
        │
 ┌──────┴────────┐
 │               │
 ▼               ▼
Build & Zip    Terraform Apply
 │               │
 ▼               ▼
Artifacts     AWS Lambda Deployment
```

---

##  Project Structure

```
.
├── lambda/
│   ├── functionA/
│   │   └── main.go
│   ├── functionB/
│   │   └── main.go
│   └── ...
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│   └── provider.tf
│   └── terraform.tfvars
├── Jenkinsfile
└── README.md
```

* Each folder under `lambda/` represents a standalone Lambda function
* Terraform manages infrastructure and deployment
* Jenkins orchestrates the pipeline

---

##  CI/CD Workflow

### 1. Trigger

* Pipeline starts when a branch is merged into `main`

### 2. Build Phase

* Each Lambda function is:

  * Compiled using Go
  * Built for Linux (`GOOS=linux`, `GOARCH=amd64`)
  * Packaged into a `.zip` file

### 3. Infrastructure Deployment

* Terraform:

  * Initializes (`terraform init`)
  * Plans (`terraform plan`)
  * Applies (`terraform apply`)
* Updates or creates Lambda functions as needed

### 4. Deployment

* Each zipped artifact is uploaded and deployed to its corresponding AWS Lambda

---

##  Key Features

*  Fully automated deployments on merge to `main`
*  Independent Lambda packaging per folder
*  Infrastructure as Code using Terraform
*  Fast Go builds optimized for AWS Lambda

---

##  Prerequisites

* Go (1.x)
* Jenkins server
* Terraform (v1.x)
* AWS account with appropriate IAM permissions
* GitHub repository integration with Jenkins

---

##  Environment Configuration

Ensure Jenkins has access to:

* AWS credentials 
* GitHub repository 

Required environment variables may include:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION
```

---

##  Local Development

To build a Lambda locally:

```bash
cd lambda/functionA
GOOS=linux GOARCH=amd64 go build -o main
zip functionA.zip main
```


---

##  Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. Merge into `main` to trigger deployment

---
