# Dev Portfolio Backend

---

## ■ Overview

本バックエンドは FastAPI を用いたREST APIであり、  
社内申請管理システムの業務ロジック・認証・データ管理を担います。

本システムでは、主に「交通費精算申請」をユースケースとして想定しています。

---

## ■ Architecture（Backend）

FastAPI  
↓  
Service Layer（ビジネスロジック）  
↓  
Repository（SQLAlchemy ORM）  
↓  
PostgreSQL（RDS）

---

## ■ Request Flow

1. Client → FastAPI Endpoint  
2. Endpoint → Service Layer  
3. Service → Repository（SQLAlchemy ORM）  
4. Repository → PostgreSQL（RDS）  
5. 処理結果をレスポンスとして返却  

---

## ■ Features

### 認証
- JWT認証（アクセストークン）
- トークン有効期限管理
- ログインAPI

### ユーザー機能
- 交通費精算申請の作成
- 自分の申請一覧取得

### 管理者機能
- 全申請一覧取得
- 申請承認 / 却下

### その他
- ロールベース認可（user / admin）
- カスタム例外設計
- ヘルスチェックAPI

---

## ■ Tech Stack（Backend Only）

- FastAPI
- SQLAlchemy
- Pydantic
- PostgreSQL
- python-jose（JWT）
- pwdlib（argon2によるパスワードハッシュ化）

---

## ■ Directory Structure

app/
├── api/                         # ルーティング・エンドポイント定義
│   ├── dependencies/            # 認証・共通依存関数
│   │   └── auth.py
│   ├── v1/
│   │   ├── endpoints/           # APIエンドポイント
│   │   │   ├── admin.py
│   │   │   ├── applications.py
│   │   │   ├── auth.py
│   │   │   ├── health.py
│   │   │   └── users.py
│   │   └── router.py            # ルーター統合
│   └── error_handlers.py        # 例外ハンドリング
├── core/                        # 設定・セキュリティ・共通処理
│   ├── config.py
│   ├── exceptions.py
│   └── security.py
├── db/                          # DB接続・初期化処理
│   ├── base.py
│   ├── models.py
│   ├── seed.py
│   └── session.py
├── models/                      # ORMモデル定義
│   ├── applications.py
│   └── users.py
├── schemas/                     # Pydanticスキーマ（入出力定義）
│   ├── applications.py
│   ├── auth.py
│   └── users.py
├── services/                    # ビジネスロジック
│   ├── applications.py
│   ├── auth.py
│   └── users.py
└── main.py                      # FastAPIエントリーポイント

tests/                           # テストコード（pytest）
├── conftest.py
├── test_health.py
└── test_users.py

---

## API Specification

本APIは `/api/v1` をプレフィックスとしたREST APIです。  
認証が必要なエンドポイントでは、HTTPヘッダーにJWTトークンを付与します。

---

### 認証ヘッダー

Authorization: Bearer <access_token>

---

<details>
<summary>認証API</summary>

### POST /api/v1/auth/login  
ユーザーログインを行い、JWTトークンを取得します。

**Request**
{
  "email": "user@example.com",
  "password": "password123"
}

**Response**
{
  "access_token": "jwt_token",
  "token_type": "bearer"
}

</details>

---

<details>
<summary>ユーザーAPI</summary>

### POST /api/v1/users  
新規ユーザーを作成します。

**Request**
{
  "name": "User",
  "email": "user@example.com",
  "password": "password123"
}

**Response**
{
  "id": 1,
  "name": "User",
  "email": "user@example.com",
  "role": "user"
}

</details>

---

<details>
<summary>申請API（交通費精算）</summary>

### POST /api/v1/applications  
交通費精算申請を作成します（認証必要）

**Request**
{
  "title": "交通費精算",
  "content": "東京-大阪 新幹線代",
  "amount": 15000,
  "application_date": "2026-04-01"
}

**Response**
{
  "id": 1,
  "user_id": 1,
  "title": "交通費精算",
  "content": "東京-大阪 新幹線代",
  "amount": 15000,
  "application_date": "2026-04-01",
  "status": "pending"
}

---

### GET /api/v1/applications/me  
ログインユーザーの申請一覧を取得します（認証必要）

**Response**
[
  {
    "id": 1,
    "title": "交通費精算",
    "status": "pending"
  }
]

</details>

---

<details>
<summary>管理者API</summary>

### GET /api/v1/admin/applications  
全ユーザーの申請一覧を取得します（admin権限）

---

### PATCH /api/v1/admin/applications/{id}/status  
申請のステータスを更新します（admin権限）

**Request（承認）**
{
  "status": "approved",
  "reject_reason": null
}

**Request（却下）**
{
  "status": "rejected",
  "reject_reason": "領収書不備"
}

</details>

---

<details>
<summary>ヘルスチェック</summary>

### GET /api/v1/health  
アプリケーションの稼働確認

**Response**
{
  "status": "ok"
}

</details>

---

### ステータス一覧

| status   | 説明     |
|----------|----------|
| pending  | 申請中   |
| approved | 承認済み |
| rejected | 却下     |

---

### エラー仕様

#### 認証・認可エラー

| ステータス | 内容                           |
|------------|--------------------------------|
| 401        | トークンなし / 無効 / 期限切れ |
| 403        | 権限不足（admin専用APIなど）   |

---

#### バリデーション / リソースエラー

| ステータス | 内容                             |
|------------|----------------------------------|
| 400        | リクエスト不正（入力値エラー等） |
| 404        | リソースが存在しない             |

---

## ■ Authentication

### 認証方式
- JWT（JSON Web Token）

### 利用方法（使い方）
Authorizationヘッダにトークンを付与

Authorization: Bearer <access_token>

---

### 認証フロー（仕組み）

1. ユーザーがログインAPIを実行  
2. サーバーがJWTトークンを発行  
3. クライアントがトークンを保持  
4. 各APIリクエスト時にAuthorizationヘッダへ付与  

---

## ■ Security

- pwdlib + argon2によるパスワードハッシュ化
- JWT署名によるトークン改ざん防止
- ロールベース認可（RBAC）によるアクセス制御
- 環境変数による機密情報管理（.env）
- HTTPS通信前提（ALB経由）

---

## ■ Environment Variables

以下は `.env.example` のサンプルです。  
実際の値は `.env` ファイルで管理してください。

APP_NAME=Dev Portfolio App  
APP_VERSION=1.0.0  
DEBUG=True  
API_V1_PREFIX=/api/v1  

# Local: Docker DB / EC2: RDS  
DATABASE_URL=postgresql+psycopg://app_user:app_password@db:5432/app_db  

SECRET_KEY=your-secret-key  
ALGORITHM=HS256  
ACCESS_TOKEN_EXPIRE_MINUTES=30  

※ インフラ構成（RDS等）は infra/README.md を参照

---

## Local Development

### 前提
- Docker / Docker Compose インストール済み

### 起動手順
ローカルでは docker-compose を使用し、アプリケーションとローカルDBをまとめて起動します。

```bash
docker compose up --build
```

### アクセス
http://localhost:8000/docs

---

## EC2 Deployment

EC2環境では、アプリケーションコンテナのみを起動し、DBはAmazon RDS for PostgreSQLを使用します。

### 1. Dockerイメージ作成

```bash
docker build -t portfolio-app .
```

### 2. コンテナ起動

```bash
docker run -d \
  --name portfolio-app \
  --restart unless-stopped \
  -p 8000:8000 \
  --env-file .env.ec2 \
  portfolio-app
```

---

## ■ Error Handling

以下のカスタム例外を使用

- AppServiceError（基底例外）
- ResourceNotFoundError
- ConflictError
- AuthenticationError
- AuthorizationError

---

## ■ Health Check

#### GET /health

ALBのターゲットグループのヘルスチェックに使用

---

## ■ Future Improvements

- リフレッシュトークン実装
- RBAC（権限管理）の高度化
- APIレート制限
- Alembicによるマイグレーション管理
- paginationの実装