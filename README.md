# 🌐 Static Website Hosting with Terraform (S3 + CloudFront)

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazonaws&logoColor=white)
![S3](https://img.shields.io/badge/Amazon_S3-569A31?style=flat&logo=amazons3&logoColor=white)
![CloudFront](https://img.shields.io/badge/CloudFront-8C4FFF?style=flat&logo=amazonaws&logoColor=white)

A fully automated, Infrastructure-as-Code static website deployment on AWS. Terraform provisions an S3 bucket for storage and a CloudFront distribution for global HTTPS delivery — the entire stack is defined as code and reproducible with a single command.

## 📐 Architecture

**Browser → CloudFront (HTTPS/CDN) → S3 Bucket (private origin)**

The S3 bucket stays private; only CloudFront is granted read access via an Origin Access Control (OAC), so the site is served fast and encrypted without exposing the bucket directly to the internet.

## 🗂️ Project Structure

```
project3-terraform-static-site/
├── main.tf          # S3 bucket, CloudFront distribution, OAC, bucket policy
├── variables.tf      # Region and bucket name inputs
├── outputs.tf          # CloudFront domain name output
├── src/
│   ├── index.html
│   └── style.css
└── .gitignore
```

## ✅ Prerequisites

- Terraform >= 1.5
- AWS CLI configured with valid credentials (`aws configure`)
- An AWS account with permissions for S3 and CloudFront

## ▶️ How to Deploy

**1. Initialize Terraform**

```bash
terraform init
```

**2. Review the execution plan**

```bash
terraform plan
```

**3. Apply the infrastructure**

```bash
terraform apply
```

Type `yes` when prompted. The S3 bucket and CloudFront distribution are created in this step — first-time CloudFront propagation can take 5–10 minutes.

**4. Access the site**

```bash
terraform output cloudfront_domain_name
```

Copy the printed domain (ends in `.cloudfront.net`) into your browser.

## 📦 Resources Provisioned

| Resource                               | Purpose                                                    |
| -------------------------------------- | ---------------------------------------------------------- |
| `aws_s3_bucket`                        | Stores the static site files, kept private                 |
| `aws_cloudfront_origin_access_control` | Lets only CloudFront read from the bucket                  |
| `aws_s3_bucket_policy`                 | Grants CloudFront (and only CloudFront) `GetObject` access |
| `aws_cloudfront_distribution`          | Serves the site globally over HTTPS with CDN caching       |

## 🧹 Cleanup

To avoid incurring unnecessary AWS charges, destroy the infrastructure when you're finished:

```bash
terraform destroy
```

Type `yes` when prompted. Wait for it to complete (about 2–3 minutes).

**Expected output:**

```
Destroy complete! Resources: 4 destroyed.
```

## 🔑 Key Learnings

- **Infrastructure as Code for static hosting** — the entire storage + CDN stack is reproducible from a single `terraform apply`, with no manual console steps.
- **Origin Access Control** — learned to keep the S3 bucket private and route all public traffic through CloudFront instead of exposing the bucket directly.
- **CDN fundamentals** — HTTPS termination, edge caching, and global distribution through CloudFront.
- **Cost discipline** — ran `terraform destroy` as soon as testing was verified, rather than leaving billable resources running.

## 🚧 Future Improvements

- [ ] Add a GitHub Actions workflow to auto-sync `src/` to S3 and invalidate the CloudFront cache on push
- [ ] Add a custom domain with an ACM certificate
- [ ] Add a `versions.tf` pinning the Terraform and AWS provider versions

## 👨‍💻 Author

**Kiya Yilma Regasa**
Cloud & DevOps Engineer

[LinkedIn](https://linkedin.com/in/your-profile) · [GitHub](https://github.com/kiyayilma-dev)
