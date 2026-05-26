# Dev Portfolio

---

## ■ Overview

Terraformを用いてAWS上に構築する、冗長化・可用性を考慮した社内向け申請管理システム基盤です。  
バックエンドにはFastAPIを採用し、認証・承認フローを含む業務ロジックを実装しています。

本プロジェクトでは、以下を重視しています：

- 実務を意識したアーキテクチャ設計
- AWSを用いた本番構成
- Dockerによる環境統一
- TerraformによるIaC化

---

## ■ Architecture

![architecture](docs/architecture.png)

### Architecture Flow

Users<br>
↓<br>
ALB（Application Load Balancer）<br>
↓<br>
EC2（Docker + FastAPI）<br>
↓<br>
RDS（PostgreSQL）

---

## ■ Request Flow

1. Users → ALB  
2. ALB → EC2（FastAPI）  
3. FastAPI → Service Layer  
4. Service → Repository Layer  
5. Repository → PostgreSQL（RDS）  
6. 処理結果をレスポンスとして返却  

---

## ■ Tech Stack

### Backend
- FastAPI
- SQLAlchemy
- Alembic
- Pydantic
- PostgreSQL
- JWT認証（OAuth2 Password Flow / python-jose）

### Infrastructure
- AWS VPC（Public / Private Subnet）
- AWS Route 53
- AWS Application Load Balancer
- AWS EC2 Auto Scaling
- AWS RDS for PostgreSQL
- AWS IAM / Security Group
- AWS WAF
- AWS Systems Manager
- AWS Secrets Manager
- AWS CloudWatch / SNS
- Slack（AWS Chatbot Notifications）

### IaC
- Terraform

### DevOps
- Docker / Docker Compose
- GitHub
- GitHub Actions（CI / CD）

---

## ■ Features

- 認証（JWT）
- 申請作成・ページネーション付き一覧取得
- 承認 / 却下フロー

---

## ■ System Design

### ネットワーク構成

- Public Subnet
  - ALB
- Private Subnet
  - EC2（アプリケーション）
  - RDS（DB）

---

### セキュリティ設計

- 認証・認可の実装
- ネットワークレベルのアクセス制御
- 機密情報の安全な管理

---

## ■ Directory Structure

```text
.
├── .github/
│   ├── scripts/
│   │   └── deploy-ec2-via-ssm.sh                # SSM経由のEC2デプロイスクリプト
│   └── workflows/
│       ├── ci.yml                               # GitHub Actions CI
│       ├── cd.yml                               # GitHub Actions CD
│       └── terraform-cd.yml                     # Terraform plan / apply
│
├── backend/                                     # FastAPIバックエンド（Docker / テスト含む）
│   ├── alembic/                                 # DBマイグレーション管理
│   ├── app/                                     # アプリケーション本体
│   ├── tests/                                   # テストコード
│   ├── docker-compose.yml                       # ローカル開発用
│   ├── Dockerfile                               # アプリケーションコンテナ定義
│   └── README.md                                # バックエンド詳細
│
├── infra/                                       # インフラ構成（Terraform）
│   ├── bootstrap/                               # Terraform Backend用S3作成
│   ├── envs/                                    # dev / prod 環境
│   ├── modules/                                 # Terraform modules
│   └── README.md                                # インフラ詳細
│
├── docs/                                        # 設計資料
│   └── architecture.png                         # システム構成図
│
├── .gitignore                                   # Git除外設定
└── README.md                                    # ルートREADME
```

---

## ■ Local Development

```bash
cd backend
docker compose up -d --build
docker compose exec app alembic upgrade head
```

### アクセス

- Local:
  - API Docs: [http://localhost:8000/docs](http://localhost:8000/docs)
  - Swagger UI から OAuth2 Password Flow によるJWT認証を実行可能

- Public:
  - API Docs: [https://app.sakuyadev.com/docs](https://app.sakuyadev.com/docs)
  - 構成: HTTPS / ALB / ACM

---

## ■ Deployment

AWS上のEC2およびRDSを利用してアプリケーションを公開しています。  
詳細は backend/README.md および infra/README.md を参照してください。

---

## ■ CI

GitHub Actions CIにより、Pull Request作成時およびmainブランチへのpush時に自動チェックを実行します。

### 実行内容

- `backend` 配下のpytest実行
- Terraformコードのformat check（`terraform fmt -check -recursive infra`）
- Terraform構成のvalidate（`infra/envs/dev` / `infra/envs/prod`）

### 対象外

- Docker image build / push
- AWS認証設定

---

## ■ CD

GitHub Actions CDにより、CI成功後または手動実行によりEC2環境へアプリケーションをデプロイします。

### 実行内容

- Docker imageのbuild / push
- GitHub Actions OIDCによるAWS認証
- AWS Systems Manager Run CommandによるEC2デプロイ
- デプロイ時のAlembic migration実行
- 既存コンテナの停止・削除と新しいコンテナの起動
- `/api/v1/health` によるヘルスチェック

### 必要なGitHub Secrets

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `AWS_ROLE_ARN`

### 必要なGitHub Variables

- `AWS_REGION`
- `DOCKER_IMAGE_NAME`
- `SSM_TARGET_KEY`
- `SSM_TARGET_VALUE`
- `APP_CONTAINER_NAME`
- `APP_ENV_FILE`
- `APP_PORT`
- `APP_HEALTH_URL`

---

## ■ Terraform CD

GitHub Actions Terraform CDにより、Terraform plan / applyを手動実行できます。

### 実行内容

- 対象環境（dev / prod）の選択
- 実行アクション（plan / apply）の選択
- GitHub Actions OIDCによるAWS認証
- Terraform Backendの初期化
- Terraform format check
- Terraform validate
- Terraform plan
- Terraform apply（apply選択時のみ）

### 必要なGitHub Secrets

- `AWS_TERRAFORM_ROLE_ARN`

### 必要なGitHub Variables

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

---

## ■ Documents

- [Backend詳細](backend/README.md)
- [Infrastructure詳細](infra/README.md)

---

## ■ Future Improvements

- Blue / Green Deployment
- Rollback自動化
- CloudWatch Dashboard の整備
- 本番運用を想定した監視・デプロイ改善

---

## ■ Author

Sakuya Aradono  
- GitHub: [sakuyaxx21-sys](https://github.com/sakuyaxx21-sys)  
- App: [app.sakuyadev.com](https://app.sakuyadev.com)
