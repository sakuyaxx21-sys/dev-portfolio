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

## ■ Architecture（全体構成）

Client（想定）  
↓  
ALB（Application Load Balancer）  
↓  
EC2（Docker + FastAPI）  
↓  
RDS（PostgreSQL）

---

## ■ Request Flow

1. Client → ALB  
2. ALB → EC2（FastAPI）  
3. FastAPI → Service Layer  
4. Service → PostgreSQL（RDS）  
5. 処理結果をレスポンスとして返却  

---

## ■ Tech Stack

### Backend
- FastAPI
- SQLAlchemy
- Pydantic
- PostgreSQL
- JWT認証（python-jose）

### Infrastructure
- AWS VPC（Public / Private Subnet）
- AWS Route 53
- AWS Application Load Balancer
- AWS EC2 Auto Scaling
- AWS RDS for PostgreSQL
- AWS WAF
- AWS IAM / Security Group
- AWS Systems Manager
- AWS Secrets Manager
- AWS CloudWatch / SNS

### IaC
- Terraform（導入予定）

### DevOps
- Docker / Docker Compose
- GitHub
- GitHub Actions（予定）

---

## ■ Features（概要）

- 認証（JWT）
- 申請作成・一覧取得
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

### セキュリティ設計（概要）

- 認証・認可の実装
- ネットワークレベルのアクセス制御
- 機密情報の安全な管理

---

## ■ Directory Structure

    .
    ├── backend/                # FastAPIバックエンド（Docker / テスト含む）
    │   ├── app/                # アプリケーション本体
    │   ├── tests/              # テストコード
    │   ├── docker-compose.yml  # ローカル開発用
    │   ├── Dockerfile          # アプリケーションコンテナ定義
    │   └── README.md           # バックエンド詳細
    │
    ├── infra/                  # インフラ構成（Terraform）
    │   └── README.md           # インフラ詳細
    │
    ├── .gitignore              # Git除外設定
    └── README.md               # ルートREADME

---

## ■ Setup（ローカル開発）

```bash
docker compose up --build
```

### アクセス

- Local: http://localhost:8000/docs
- Public: https://sakuyadev.com/docs（HTTPS / ALB + ACM）

---

## ■ Deployment（概要）

AWS上のEC2およびRDSを利用してアプリケーションを公開しています。  
詳細は各READMEを参照してください。

---

## ■ Documents

- [Backend詳細](./backend/README.md)
- [Infrastructure詳細](./infra/README.md)

---

## ■ Future Improvements

- Terraformによる完全IaC化
- CI/CD（GitHub Actions）
- 監視・アラートの強化（CloudWatch / SNS）

---

## ■ Author

Sakuya Aradono  
GitHub: https://github.com/sakuyaxx21-sys  
Portfolio: https://sakuyadev.com