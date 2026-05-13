# Dev Portfolio Infrastructure

---

## ■ Overview

本インフラは Terraform を用いて AWS 上に構築する、  
社内向け申請管理システムの実行基盤です。

FastAPI アプリケーションを ALB / EC2 Auto Scaling / RDS PostgreSQL で構成し、  
HTTPS、WAF、Secrets Manager、CloudWatch によるセキュリティ・運用監視を含みます。

---

## ■ Architecture（Infrastructure）

Client  
↓  
Route 53  
↓  
ALB（HTTPS / ACM / WAF）  
↓  
EC2 Auto Scaling Group（Docker + FastAPI）  
↓  
RDS PostgreSQL（Private DB Subnet）

---

## ■ Request Flow

1. Client → Route 53  
2. Route 53 → ALB  
3. ALB → EC2（FastAPI）  
4. FastAPI → RDS PostgreSQL  
5. 処理結果をレスポンスとして返却

---

## ■ Tech Stack（Infrastructure）

- Terraform
- AWS VPC（Public / Private Subnet）
- AWS Internet Gateway
- AWS NAT Gateway
- AWS Route 53
- AWS ACM
- AWS Application Load Balancer
- AWS EC2 Auto Scaling
- AWS RDS for PostgreSQL
- AWS WAF
- AWS IAM / Security Group
- AWS Systems Manager
- AWS Secrets Manager
- AWS KMS
- AWS CloudWatch / SNS
- AWS Chatbot
- Slack
- Amazon S3（Terraform State / ALB Access Logs）

---

## ■ System Design

### ネットワーク構成

- Public Subnet
  - ALB
  - NAT Gateway

- Private App Subnet
  - EC2 Auto Scaling Group

- Private DB Subnet
  - RDS PostgreSQL

---

### セキュリティ設計

- ALB のみインターネットから HTTP / HTTPS を許可
- HTTP（80）アクセスは HTTPS（443）へリダイレクト
- EC2 は ALB からのアプリケーションポートのみ許可
- RDS は EC2 からの PostgreSQL 接続のみ許可
- EC2 への直接 SSH 接続は行わず、Systems Manager を利用
- アプリケーションの機密情報は Secrets Manager で管理
- RDS ストレージとアプリケーション Secret は KMS で暗号化
- ALB に AWS WAF を関連付け

---

## ■ Directory Structure

```text
infra/
├── bootstrap/                                   # Terraform Backend用S3バケット作成
├── envs/
│   ├── dev/                                     # dev環境
│   └── prod/                                    # prod環境
├── modules/
│   ├── app/                                     # ALB / ACM / Route 53 / EC2 Auto Scaling / user_data
│   ├── db/                                      # RDS PostgreSQL
│   ├── monitoring/                              # CloudWatch Alarm
│   ├── network/                                 # VPC / Subnet / NAT Gateway / Security Group
│   ├── operations/                              # Logs / SNS / Chatbot / ALB Access Logs
│   └── security/                                # IAM / WAF / KMS / Secrets Manager
├── .terraform-version                           # Terraform version
└── README.md                                    # インフラ詳細
```

---

## ■ Environments

### dev

検証用環境です。  
コストを抑えるため、NAT Gateway は 1 台、RDS Multi-AZ と削除保護は無効です。

### prod

本番想定環境です。  
可用性と保護を重視し、NAT Gateway は 2 台、RDS Multi-AZ と削除保護を有効化します。

---

## ■ Terraform Backend

Terraform State は S3 Backend で管理します。  
Backend 用 S3 バケットは `infra/bootstrap` で作成します。  
Terraform 1.10 以降でサポートされた `use_lockfile` を使用し、  
DynamoDB を用いないシンプルな state lock 構成を採用しています。

```bash
cd infra/bootstrap
terraform init
terraform plan
terraform apply
```

---

## ■ Deployment

### 1. 環境ディレクトリへ移動

```bash
cd infra/envs/dev
```

### 2. Terraform 初期化

```bash
terraform init
```

### 3. 実行計画の確認

```bash
terraform plan
```

### 4. リソース作成

```bash
terraform apply
```

※ 本番環境へ適用する場合は `infra/envs/prod` を使用してください。

---

## ■ Application Runtime

EC2 は Launch Template の user data により、アプリケーションコンテナを自動起動します。

### EC2 User Data

EC2 起動時に user data で以下を実行します。

- 必要パッケージのインストール
  - Docker
  - Git
  - jq
  - AWS CLI
  - CloudWatch Agent
- Docker サービスの有効化・起動
- GitHub リポジトリからアプリケーションコードを取得
- Secrets Manager から以下の値を取得
  - アプリケーション Secret
  - RDS master user secret
- RDS 接続情報をもとに `.env.ec2` を生成
- CloudWatch Agent 設定ファイルを配置
- CloudWatch Agent を起動
- Docker イメージをビルド
- 既存コンテナを停止・削除
- FastAPI アプリケーションコンテナを起動

```bash
docker build -t ${app_name}-backend .

docker stop ${app_name}-backend || true
docker rm ${app_name}-backend || true

docker run -d \
  --name ${app_name}-backend \
  -p 8000:8000 \
  --env-file .env.ec2 \
  --restart unless-stopped \
  ${app_name}-backend
```

---

## ■ Monitoring / Logs

### CloudWatch Logs

- EC2 cloud-init logs
- EC2 cloud-init-output logs
- EC2 SSM logs
- Docker application logs
- WAF logs

### CloudWatch Alarms

- Auto Scaling Group の稼働台数
- EC2 CPU 使用率
- Target Group の UnHealthyHostCount
- ALB / Target Group の 5XX エラー
- RDS CPU 使用率
- RDS 空きストレージ
- RDS 接続数

### Notifications

CloudWatch Alarm は SNS を経由し、AWS Chatbot で Slack に通知します。

---

## ■ Outputs

主な Terraform Output は以下です。

- ALB DNS Name
- Application URL
- Route 53 Record
- ACM Certificate ARN
- RDS Endpoint
- Auto Scaling Group Name
- Secrets Manager Secret Name
- SNS Topic ARN
- CloudWatch Log Group Name

---

## ■ Future Improvements

- GitHub Actions による Terraform plan / apply の自動化
- Docker Hub を利用したコンテナイメージ配布
- Blue / Green Deployment
- CloudWatch Dashboard の整備
- WAF ルールの追加・チューニング
