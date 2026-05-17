# Dev Portfolio Backend

---

## ■ Overview

本バックエンドは FastAPI を用いた REST API であり、  
社内向け申請管理システムの業務ロジック・認証・データ管理を担います。

申請作成、承認、ユーザー管理などを API として提供し、  
JWT 認証によるステートレスな認証方式を採用しています。

本システムでは、主に「交通費精算申請」をユースケースとして想定しています。

---

## ■ Architecture（Backend）

Users<br>
↓<br>
FastAPI Router<br>
↓<br>
Dependencies（認証 / DB Session）<br>
↓<br>
Service Layer（ビジネスロジック）<br>
↓<br>
SQLAlchemy ORM<br>
↓<br>
PostgreSQL（RDS）

---

## ■ Request Flow

1. Users → FastAPI Router  
2. Router → Dependencies（認証 / DB Session）  
3. Router → Service Layer  
4. Service → SQLAlchemy ORM  
5. SQLAlchemy ORM → PostgreSQL（RDS）  
6. 処理結果をレスポンスとして返却  

---

## ■ Features

### 認証
- JWT認証（アクセストークン）
- トークン有効期限管理
- ログインAPI

### ユーザー機能
- 交通費精算申請の作成
- 自分の申請一覧取得（pagination対応）

### 管理者機能
- 全申請一覧取得（検索 / 絞り込み / pagination対応）
- 申請承認 / 却下

### その他
- ロールベース認可（user / admin）
- カスタム例外設計
- ヘルスチェックAPI

---

## ■ Tech Stack（Backend）

- FastAPI
- SQLAlchemy
- Pydantic
- PostgreSQL
- python-jose（JWT）
- OAuth2PasswordBearer / OAuth2PasswordRequestForm
- python-multipart（OAuth2 form data）
- pwdlib（argon2によるパスワードハッシュ化）

---

## ■ System Design

### レイヤ構成

- Router / Dependencies / Service / DB のレイヤ構成
- Dependencies で認証ユーザー取得・DB Session 注入を実施
- Service 層でビジネスロジックを分離
- Service 層から SQLAlchemy ORM を利用して DB 操作を実行
- SQLAlchemy ORM による DB 抽象化
- Custom Exception による例外責務分離
- JWT 認証によるステートレス設計

---

### セキュリティ設計

- pwdlib + argon2によるパスワードハッシュ化
- JWT署名によるトークン改ざん防止
- ロールベース認可（RBAC）によるアクセス制御
- 環境変数による機密情報管理（.env）
- HTTPS通信前提（ALB経由）

---

## ■ Directory Structure

```text
backend/
├── app/
│   ├── api/
│   │   ├── dependencies/                        # 認証・共通依存関数
│   │   │   └── auth.py
│   │   ├── v1/
│   │   │   ├── endpoints/                       # APIエンドポイント
│   │   │   │   ├── admin.py
│   │   │   │   ├── applications.py
│   │   │   │   ├── auth.py
│   │   │   │   ├── health.py
│   │   │   │   └── users.py
│   │   │   └── router.py                        # ルーター統合
│   │   └── error_handlers.py                    # 例外ハンドリング
│   │
│   ├── core/                                    # 設定・セキュリティ・共通処理
│   ├── db/                                      # DB接続・初期化処理
│   ├── models/                                  # ORMモデル定義
│   ├── schemas/                                 # Pydanticスキーマ
│   ├── services/                                # ビジネスロジック
│   └── main.py                                  # FastAPIエントリーポイント
│
├── tests/                                       # テストコード（pytest）
├── .env.example                                 # 環境変数サンプル
├── docker-compose.yml                           # ローカル開発用
├── Dockerfile                                   # アプリケーションコンテナ定義
├── requirements.txt                             # Python依存関係
└── README.md                                    # バックエンド詳細
```

---

## ■ API Specification

詳細なAPI仕様およびリクエスト/レスポンス確認は Swagger UI を参照してください。

本APIは `/api/v1` をプレフィックスとしたREST APIです。  
認証が必要なエンドポイントでは、HTTPヘッダーにJWTトークンを付与します。

---

### 認証ヘッダー

`Authorization: Bearer {access_token}`

---

<details>
<summary>認証API</summary>

### POST /api/v1/auth/login  
- ユーザーログインを行い、JWTトークンを取得

**Request**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response**
```json
{
  "access_token": "jwt_token",
  "token_type": "bearer"
}
```

---

### POST /api/v1/auth/token
- Swagger UI の OAuth2 Password Flow 用トークン取得API
- `OAuth2PasswordRequestForm` により `application/x-www-form-urlencoded` を受け取る
- `username` には email を指定する

**Request（form-data）**
```text
username=user@example.com
password=password123
```

**Response**
```json
{
  "access_token": "jwt_token",
  "token_type": "bearer"
}
```

</details>

---

<details>
<summary>ユーザーAPI</summary>

### POST /api/v1/users  
- 新規ユーザーを作成

**Request**
```json
{
  "name": "User",
  "email": "user@example.com",
  "password": "password123"
}
```

**Response**
```json
{
  "id": 1,
  "name": "User",
  "email": "user@example.com",
  "role": "user"
}
```

</details>

---

<details>
<summary>申請API（交通費精算）</summary>

### POST /api/v1/applications  
- 交通費精算申請を作成（認証必要）

**Request**
```json
{
  "title": "交通費精算",
  "content": "東京-大阪 新幹線代",
  "amount": 15000,
  "application_date": "2026-04-01"
}
```

**Response**
```json
{
  "id": 1,
  "user_id": 1,
  "title": "交通費精算",
  "content": "東京-大阪 新幹線代",
  "amount": 15000,
  "application_date": "2026-04-01",
  "status": "pending"
}
```

---

### GET /api/v1/applications/me  
- ログインユーザーの申請一覧を取得（認証必要）
- `page` / `limit` によるpaginationに対応

**Request例**
```text
GET /api/v1/applications/me?page=1&limit=10
```

**Query Parameters**

| name  | default | validation | 説明 |
|-------|---------|------------|------|
| page  | 1       | 1以上       | 取得するページ番号 |
| limit | 10      | 1〜100      | 1ページあたりの取得件数 |

**Response**
```json
{
  "items": [
    {
      "id": 1,
      "user_id": 1,
      "title": "交通費精算",
      "content": "東京-大阪 新幹線代",
      "amount": 15000,
      "application_date": "2026-04-01",
      "status": "pending",
      "reject_reason": null,
      "reviewd_by": null,
      "reviewed_at": null,
      "created_at": "2026-04-01T00:00:00",
      "updated_at": "2026-04-01T00:00:00"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 10,
  "total_pages": 1
}
```

</details>

---

<details>
<summary>管理者API</summary>

### GET /api/v1/admin/applications  
- 全ユーザーの申請一覧を取得（admin権限）
- `status` / `user_id` / `keyword` で絞り込み可能
- `page` / `limit` によるpaginationに対応

**Request例**
```text
GET /api/v1/admin/applications?status=pending&page=1&limit=10
```

**Query Parameters**

| name    | default | validation | 説明 |
|---------|---------|------------|------|
| status  | -       | -          | 申請ステータスで絞り込み |
| user_id | -       | -          | ユーザーIDで絞り込み |
| keyword | -       | -          | 申請タイトルでキーワード検索 |
| page    | 1       | 1以上       | 取得するページ番号 |
| limit   | 10      | 1〜100      | 1ページあたりの取得件数 |

**Response**
```json
{
  "items": [
    {
      "id": 1,
      "user_id": 1,
      "title": "交通費精算",
      "content": "東京-大阪 新幹線代",
      "amount": 15000,
      "application_date": "2026-04-01",
      "status": "pending",
      "reject_reason": null,
      "reviewd_by": null,
      "reviewed_at": null,
      "created_at": "2026-04-01T00:00:00",
      "updated_at": "2026-04-01T00:00:00"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 10,
  "total_pages": 1
}
```

---

### PATCH /api/v1/admin/applications/{id}/status  
- 申請のステータスを更新（admin権限）

**Request（承認）**
```json
{
  "status": "approved",
  "reject_reason": null
}
```

**Request（却下）**
```json
{
  "status": "rejected",
  "reject_reason": "領収書不備"
}
```

</details>

---

<details>
<summary>ヘルスチェック</summary>

### GET /api/v1/health  
- アプリケーションの稼働状態を確認
- ALBターゲットグループのヘルスチェックに使用

**Response**
```json
{
  "status": "ok"
}
```

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

以下のカスタム例外を使用

- AppServiceError（基底例外）
- ResourceNotFoundError
- ConflictError
- AuthenticationError
- AuthorizationError

---

#### 認証・認可エラー

| ステータス | 内容                           |
|------------|--------------------------------|
| 401        | トークンなし / 無効 / 期限切れ |
| 403        | 権限不足（admin専用APIなど）   |

---

#### バリデーション / リソースエラー

| ステータス | 内容                                           |
|------------|------------------------------------------------|
| 400        | リクエスト不正（業務ルール上の入力エラー等） |
| 404        | リソース、またはAPIパスが存在しない           |
| 405        | 許可されていないHTTPメソッド                  |
| 422        | FastAPI / Pydantic によるリクエスト検証エラー |

例: request body の必須項目不足、型不一致、`page` が 1 未満、`limit` が 1〜100 の範囲外の場合は 422 を返します。

---

## ■ Authentication / Authorization

### 認証方式
- JWT（JSON Web Token）
- OAuth2 Password Flow
- Bearer Token

### 利用方法（使い方）
Authorizationヘッダにトークンを付与

`Authorization: Bearer {access_token}`

Swagger UI（`/docs`）では `Authorize` ボタンから OAuth2 Password Flow を利用します。  
`username` には登録済みの email を入力します。

---

### 実装方式
- `OAuth2PasswordBearer` により Authorization ヘッダの Bearer Token を取得
- `OAuth2PasswordRequestForm` により Swagger UI 用のログインフォームを受け取る
- `/api/v1/auth/login` は JSON ログイン用として維持
- `/api/v1/auth/token` は Swagger UI / OAuth2 Password Flow 用として利用

---

### 認証フロー（仕組み）

1. ユーザーがログインAPIを実行  
2. サーバーがJWTトークンを発行  
3. クライアントがトークンを保持  
4. 各APIリクエスト時にAuthorizationヘッダへ付与  

---

## ■ Environment Variables

以下は `.env.example` のサンプルです。  
実際の値は `.env` ファイルで管理してください。

```env
APP_NAME=Dev Portfolio App  
APP_VERSION=1.0.0  
DEBUG=True  
API_V1_PREFIX=/api/v1  

# Local: Docker DB / EC2: RDS  
DATABASE_URL=postgresql+psycopg://app_user:app_password@db:5432/app_db  

SECRET_KEY=your-secret-key  
ALGORITHM=HS256  
ACCESS_TOKEN_EXPIRE_MINUTES=30
```  

※ インフラ構成（RDS等）は infra/README.md を参照

---

## ■ Local Development

### 前提
- Docker / Docker Compose インストール済み

### 起動手順
ローカルでは docker-compose を使用し、アプリケーションとローカルDBをまとめて起動します。

```bash
docker compose up --build
```

### アクセス

- Local:
  - API Docs: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## ■ EC2 Deployment

EC2環境では、アプリケーションコンテナのみを起動し、DBはAmazon RDS for PostgreSQLを使用します。

RDS接続情報はTerraformで作成したSecrets Managerから取得し、EC2起動時に `.env.ec2` として生成します。

### 1. Dockerイメージ作成

```bash
docker build -t dev-portfolio-backend .
```

### 2. コンテナ起動

```bash
docker run -d \
  --name dev-portfolio-backend \
  -p 8000:8000 \
  --env-file .env.ec2 \
  --restart unless-stopped \
  dev-portfolio-backend
```

---

## ■ Future Improvements

- Alembicによるマイグレーション管理
- リフレッシュトークン実装
- RBAC（権限管理）の高度化
- APIレート制限
