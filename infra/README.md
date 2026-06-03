# Dev Portfolio Infrastructure

---

## ■ Overview

本インフラはTerraformを用いてAWS上に構築する、  
社内向け申請管理システムの実行基盤です。  

FastAPIアプリケーションをALB / EC2 Auto Scaling / RDS PostgreSQLで構成し、  
HTTPS / WAF / Secrets Manager / CloudWatchによるセキュリティ・運用監視を含みます。  

---

## ■ Architecture（Infrastructure）

```text
Users
↓
Route 53
↓
ALB（HTTPS / ACM / WAF）
↓
EC2 Auto Scaling Group（Docker + FastAPI）
↓
RDS PostgreSQL（Private DB Subnet）
```

---

## ■ Request Flow

1. Users → Route 53
2. Route 53 → ALB
3. ALB → EC2（FastAPI）
4. FastAPI → RDS PostgreSQL
5. 処理結果をレスポンスとして返却

---

## ■ Tech Stack（Infrastructure）

- Terraform
- Amazon S3（Terraform State / ALB Access Logs）
- AWS VPC（Public / Private Subnet）
- AWS Internet Gateway
- AWS NAT Gateway
- AWS Route 53
- AWS ACM
- AWS Application Load Balancer
- AWS EC2 Auto Scaling
- AWS RDS for PostgreSQL
- AWS IAM / Security Group
- AWS WAF
- AWS Systems Manager
- AWS Secrets Manager
- AWS KMS
- AWS CloudWatch / SNS
- AWS Chatbot
- Slack
- GitHub Actions OIDC

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

- ALBのみインターネットからHTTP / HTTPSを許可
- HTTP（80）アクセスはHTTPS（443）へリダイレクト
- EC2はALBからのアプリケーションポートのみ許可
- RDSはEC2からのPostgreSQL接続のみ許可
- EC2への直接SSH接続は行わず、Systems Managerを利用
- アプリケーションの機密情報はSecrets Managerで管理
- RDSストレージとアプリケーションSecretはKMSで暗号化
- ALBにAWS WAFを関連付け

---

## ■ Directory Structure

```text
infra/
├── bootstrap/                                   # Terraform Backend用S3バケット作成
├── envs/
│   ├── dev/                                     # dev環境
│   └── prod/                                    # prod環境
├── modules/
│   ├── app/                                     # app runtime
│   ├── db/                                      # RDS PostgreSQL
│   ├── monitoring/                              # CloudWatch Alarm
│   ├── network/                                 # VPC / Subnet / NAT / SG
│   ├── operations/                              # Logs / SNS / Chatbot
│   └── security/                                # IAM / WAF / KMS / Secrets Manager
├── .terraform-version                           # Terraform version
└── README.md                                    # インフラ詳細
```

---

## ■ Environments

### dev

検証用環境です。  
コストを抑えるため、NAT Gatewayは1台、RDS Multi-AZと削除保護は無効です。  

### prod

本番想定環境です。  
可用性と保護を重視し、NAT Gatewayは2台、RDS Multi-AZと削除保護を有効化します。  

---

## ■ Terraform Backend

Terraform StateはS3 Backendで管理します。  
Backend用S3バケットは `infra/bootstrap` で作成します。  
Terraform 1.10以降でサポートされた `use_lockfile` を使用し、  
DynamoDBを用いないシンプルなstate lock構成を採用しています。  

ローカルで特定のAWS CLI profileを利用する場合は、`AWS_PROFILE` を指定して実行します。  

```bash
cd infra/bootstrap
AWS_PROFILE=terraform-dev terraform init
AWS_PROFILE=terraform-dev terraform plan
AWS_PROFILE=terraform-dev terraform apply
```

---

## ■ Deployment

### 1. 環境ディレクトリへ移動

```bash
cd infra/envs/dev
```

### 2. Terraform 初期化

```bash
AWS_PROFILE=terraform-dev terraform init
```

### 3. 実行計画の確認

```bash
AWS_PROFILE=terraform-dev terraform plan
```

### 4. リソース作成

```bash
AWS_PROFILE=terraform-dev terraform apply
```

※ 本番環境へ適用する場合は `infra/envs/prod` を使用してください。  

---

## ■ Application Runtime

EC2はLaunch Templateのuser dataにより、アプリケーションコンテナを自動起動します。  

### EC2 User Data

EC2起動時にuser dataで以下を実行します。  

- 必要パッケージのインストール
  - Docker
  - jq
  - AWS CLI
  - CloudWatch Agent
- Dockerサービスの有効化・起動
- Secrets Managerから以下の値を取得
  - アプリケーションSecret
  - RDS master user secret
- RDS接続情報をもとに `.env.ec2` を生成
- CloudWatch Agent設定ファイルを配置
- CloudWatch Agentを起動
- Docker HubからDocker imageをpull
- Alembic migrationを適用
- 既存コンテナを停止・削除
- FastAPIアプリケーションコンテナを起動

```bash
docker pull ${docker_image_name}:${docker_image_tag}

docker run --rm \
  --env-file .env.ec2 \
  ${docker_image_name}:${docker_image_tag} \
  alembic upgrade head

docker stop ${app_name}-app || true
docker rm ${app_name}-app || true

docker run -d \
  --name ${app_name}-app \
  -p 8000:8000 \
  --env-file .env.ec2 \
  --restart unless-stopped \
  ${docker_image_name}:${docker_image_tag}
```

---

## ■ Terraform CI

GitHub Actions CIでは、Pull Request作成時およびmainブランチへのpush時にTerraformの基本チェックを実行します。  

### Terraform CI 実行内容

- Terraformコードのformat check（`terraform fmt -check -recursive infra`）
- `infra/envs/dev` の `terraform validate`
- `infra/envs/prod` の `terraform validate`

CIでは `terraform init -backend=false` を使用し、S3 Backendへ接続せずに構成検証を行います。  

---

## ■ Terraform CD

GitHub Actions Terraform CDでは、手動実行によりTerraform plan / applyを実行します。  

### Terraform CD 実行内容

- 対象環境（dev / prod）の選択
- 実行アクション（plan / apply）の選択
- GitHub Actions OIDCによるAWS認証
- Terraform Backendの初期化
- Terraform format check
- Terraform validate
- Terraform plan
- Terraform apply（apply選択時のみ）

### Terraform CD で設定する値

Secrets:

- `AWS_TERRAFORM_ROLE_ARN`

Variables:

- `AWS_REGION`
- `TF_PROJECT`
- `TF_DOCKER_IMAGE_NAME`
- `TF_DOCKER_IMAGE_TAG`
- `TF_GITHUB_ACTIONS_REPOSITORY`
- `TF_GITHUB_ACTIONS_BRANCH`
- `TF_DOMAIN_NAME`
- `TF_APP_DOMAIN_NAME`
- `TF_SLACK_TEAM_ID`
- `TF_SLACK_CRITICAL_CHANNEL_ID`
- `TF_SLACK_WARNING_CHANNEL_ID`
- `TF_GITHUB_ACTIONS_OIDC_PROVIDER_ARN`（既存OIDC Providerを利用する環境のみ）

### 運用方針

`apply` は破壊的変更を含む可能性があるため、GitHub Environmentsの承認設定を利用して実行前にレビューします。  

---

## ■ GitHub Actions CD

GitHub Actions CDでは、Terraformで作成したOIDC用IAM Roleを利用してAWSへ認証します。  

GitHub Actions OIDC ProviderはAWSアカウント単位で共有するため、  
同一AWSアカウント内の別環境で既存Providerを利用する場合は  
`github_actions_oidc_provider_arn` に既存ARNを指定します。  

### GitHub Actions CD 実行内容

- Docker imageのbuild / push
- AWS Systems Manager Run CommandによるEC2デプロイ
- Alembic migrationの適用
- アプリケーションコンテナの再起動
- デプロイ後のヘルスチェック

### GitHub Actions CD で設定する値

Secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `AWS_ROLE_ARN`

Variables:

- `AWS_REGION`
- `DOCKER_IMAGE_NAME`
- `SSM_TARGET_KEY`
- `SSM_TARGET_VALUE`
- `APP_CONTAINER_NAME`
- `APP_ENV_FILE`
- `APP_PORT`
- `APP_HEALTH_URL`

---

## ■ Monitoring / Logs

### CloudWatch Logs

- EC2 cloud-init logs
- EC2 cloud-init-output logs
- EC2 SSM logs
- Docker application logs
- WAF logs

### CloudWatch Alarms

監視対象:

- Auto Scaling Groupの稼働台数
- EC2 CPU 使用率
- Target GroupのUnHealthyHostCount
- Target Groupの5XXエラー
- ALBの5XXエラー
- RDS CPU 使用率
- RDS 空きストレージ
- RDS 接続数

命名規則:

Alarm名は以下の形式で統一します。  

```text
{env}-{project}-ops-alarm-{resource}-{metric}-{severity}
```

`severity` は以下の値を使用します。  

- `crit`: 障害対応が必要なCritical Alarm
- `warn`: 注意喚起レベルのWarning Alarm

Critical Alarm:

- `GroupInServiceInstances` / `GroupDesiredCapacity`
- `UnHealthyHostCount`
- `HTTPCode_ELB_5XX_Count`
- `FreeStorageSpace`

Warning Alarm:

- ASG `CPUUtilization`
- `HTTPCode_Target_5XX_Count`
- RDS `CPUUtilization`
- `DatabaseConnections`

Alarm名の例:

```text
dev-portfolio-ops-alarm-asg-capacity-crit
dev-portfolio-ops-alarm-asg-cpu-warn
dev-portfolio-ops-alarm-target-unhealthy-crit
dev-portfolio-ops-alarm-target-5xx-warn
dev-portfolio-ops-alarm-alb-5xx-crit
dev-portfolio-ops-alarm-rds-cpu-warn
dev-portfolio-ops-alarm-rds-storage-crit
dev-portfolio-ops-alarm-rds-connections-warn
```

### Notifications

CloudWatch AlarmはSNSを経由し、AWS ChatbotでSlackに通知します。  
critical / warningごとにSNS TopicとAWS Chatbot Slack Channel Configurationを分離します。  

- Critical Alarm: #dev-portfolio-alerts-criticalへ通知
- Warning Alarm: #dev-portfolio-alerts-warningへ通知

---

## ■ Outputs

代表的なTerraform Outputは以下です。  

- Application URL
- Route 53 Record
- ALB DNS Name
- ACM Certificate ARN
- RDS Endpoint
- Secrets Manager Secret Name
- Auto Scaling Group Name
- GitHub Actions OIDC Provider ARN
- GitHub Actions CD Role ARN
- GitHub Actions Terraform Role ARN
- SNS Topic ARN（critical / warning）
- CloudWatch Log Group Name

---

## ■ Future Improvements

- IAM権限の最小権限化
- WAFルールの追加・チューニング
- Blue / Green Deployment
- Rollback自動化
- CloudWatch Dashboardの整備
