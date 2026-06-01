# 要件定義書

---

## ■ Overview

本ドキュメントは、社内向け申請管理システム基盤の業務要件およびシステム要件を定義し、  
実装対象とする機能・非機能要件・制約条件を整理するものです。  

本システムは、社内における申請業務をWeb APIとして管理し、  
申請作成、一覧確認、承認 / 却下を一元的に扱える状態を目指します。  

インフラはTerraformでAWS上に構築し、可用性、セキュリティ、運用性、コストを考慮した構成とします。  

---

## ■ System Summary

### システム名

社内向け申請管理システム基盤

### 利用者

- 一般社員
- 管理者（承認者）

### 利用目的

- 社内申請の作成・承認・管理を一元化する
- 申請状況を可視化し、確認・承認作業を効率化する
- AWS / Terraform / FastAPI を用いた実務想定のWebシステム基盤を構築する

### 利用規模

- 総ユーザー数: 最大500ユーザー
- 同時接続数: 最大100ユーザー

---

## ■ Business Flow

1. 一般社員がログインする
2. 一般社員が申請を作成する
3. 一般社員が自身の申請一覧を確認する
4. 管理者が全ユーザーの申請一覧を確認する
5. 管理者が申請内容を確認し、承認または却下する
6. 一般社員が申請結果を確認する

---

## ■ Functional Requirements

### 認証機能

- ユーザーはemailとpasswordでログインできる
- 認証成功時にJWTアクセストークンを発行する
- 認証失敗時はエラーを返却する
- Swagger UIからOAuth2 Password Flowで認証できる

### ユーザー機能

- ユーザーを作成できる
- ユーザー一覧を取得できる
- ユーザー詳細を取得できる
- ユーザー情報を更新できる
- ユーザーを削除できる
- ログイン中ユーザー自身の情報を取得できる

### 申請機能

- 一般社員は申請を作成できる
- 申請にはタイトル、内容、金額、申請日を登録できる
- 申請作成時の初期ステータスは `pending` とする
- 一般社員は自身の申請一覧をpagination付きで取得できる
- 一覧レスポンスには `items` / `total` / `page` / `limit` / `total_pages` を含める

### 管理者機能

- 管理者は全ユーザーの申請一覧をpagination付きで取得できる
- 管理者は申請一覧を `status` / `user_id` / `keyword` で絞り込める
- 管理者は申請を `approved` または `rejected` に更新できる
- 却下時は `reject_reason` を登録できる
- 承認時は既存の却下理由を保持しない
- 承認 / 却下の実行者と実行日時を記録する

### ヘルスチェック機能

- `/api/v1/health` でアプリケーションの稼働状態を確認できる
- ALB Target Groupのヘルスチェックにも同endpointを利用する

---

## ■ Interface Requirements

本システムはREST APIとして提供し、JSON形式のリクエスト / レスポンスを基本とします。  

- APIはバージョン管理されたURL体系で提供する
- 認証が必要な操作ではBearer tokenを利用する
- Swagger UIから認証付きAPIを検証できる
- 一覧取得APIはpage / limitによるpaginationに対応する
- 入力値が不正な場合は登録・更新を行わず、エラーを返却する
- 権限が不足している場合は処理を許可しない

---

## ■ Data Requirements

本システムでは、以下のデータを管理対象とします。  
物理テーブル、カラム、制約の詳細は基本設計書で定義します。  

### ユーザー

- ユーザー名
- メールアドレス
- パスワード認証情報
- 権限種別（一般ユーザー / 管理者）

### 申請

- 申請者
- 申請タイトル
- 申請内容
- 金額
- 申請日
- 申請ステータス
- 却下理由
- 承認 / 却下した管理者
- 承認 / 却下日時
- 作成日時
- 更新日時

---

## ■ Non-Functional Requirements

### 可用性

- AWS東京リージョン（`ap-northeast-1`）を利用する
- Public Subnet、Private App Subnet、Private DB Subnetを2AZに配置する
- ALBとAuto Scaling Groupによりアプリケーション層の可用性を確保する
- prod環境ではRDS Multi-AZを有効化する
- dev環境ではコストを考慮し、RDS Multi-AZと削除保護を無効化する
- CloudWatch Alarmにより異常を検知し、SNS / AWS Chatbot経由でSlackへ通知する

### 性能

- 同時接続数100ユーザーを想定する
- 主要APIは通常利用時に3秒以内の応答を目標とする
- 申請一覧はpaginationによりレスポンス肥大化を抑える
- Auto Scaling Groupにより将来的なスケールアウトを可能とする

### セキュリティ

- インターネットからの入口はALBに限定する
- HTTPアクセスはHTTPSへリダイレクトする
- TLS証明書はACMで管理する
- ALBにはWAFを関連付け、AWS Managed Rulesにより一般的なWeb攻撃を防御する
- EC2とRDSはPrivate Subnetに配置し、外部から直接アクセスさせない
- EC2への運用接続はSystems Managerを利用し、SSH接続は行わない
- パスワードはargon2でハッシュ化する
- 認証にはJWTを利用する
- DB認証情報とアプリケーションSecretはSecrets Managerで管理する
- 保存データとSecretはKMSで暗号化する

### 運用・保守

- インフラ構成はTerraformで管理する
- DBスキーマはAlembicでマイグレーション管理する
- CIでpytest、Terraform format check、Terraform validateを実行する
- CDでDocker image build / push、SSM Run CommandによるEC2デプロイ、Alembic migration、ヘルスチェックを実行する
- Terraform plan / applyはGitHub Actionsから手動実行できる
- CloudWatch LogsでOSログ、Dockerコンテナログ、運用ログを収集する
- ALBアクセスログはS3に保存する
- CloudWatch Alarmは `crit` / `warn` のseverityで通知先を分離する

### コスト

- dev環境は低コストで検証しやすい構成とする
- prod環境は本番想定としてRDS Multi-AZ、削除保護、バックアップ保持を有効化する
- NAT Gateway数、ログ保持期間、バックアップ保持期間は環境ごとに調整可能とする
- 不要なリソースを残さないようTerraformで管理する

---

## ■ Infrastructure Requirements

### ネットワーク

- AWS東京リージョンを利用する
- Public Subnet と Private Subnet を分離する
- アプリケーション層とデータベース層を異なるPrivate Subnetに配置する
- インターネットから直接到達できる入口はALBに限定する
- アプリケーション層は外部から直接アクセスできない構成とする
- データベース層はアプリケーション層からのみ接続できる構成とする
- Private App Subnetから必要な外部通信を行える構成とする
- 複数Availability Zoneにまたがる構成とし、可用性を確保する

### 主要コンポーネント

- DNS / HTTPS / Web入口
- アプリケーション実行基盤
- データベース
- 認証情報管理
- 暗号化
- 監視・ログ
- 通知
- CI/CD連携

---

## ■ Constraints

- 本システムはポートフォリオ用途の個人開発として構築する
- クラウド基盤はAWSを利用する
- インフラはTerraformで管理する
- アプリケーションはFastAPIとPostgreSQLを中心に構成する
- 過剰な高可用構成は避け、dev / prodの環境差分によりコストと本番想定を両立する
- 外部サービス連携はGitHub Actions、Docker Hub、Slack通知に限定する

---

## ■ Glossary

| 用語 | 説明 |
| --- | --- |
| 申請 | 一般社員が登録する業務依頼データ |
| 承認 | 管理者による申請の許可処理 |
| 却下 | 管理者による申請の不許可処理 |
| JWT | 認証状態を表現する署名付きトークン |
| RBAC | roleに基づくアクセス制御 |
| VPC | AWS上で論理的に分離されたネットワーク |
| AZ | AWSリージョン内の独立したデータセンター群 |
| ALB | HTTP / HTTPSリクエストを分散するロードバランサー |
| ASG | EC2台数を管理するAuto Scaling Group |
| RTO | 障害発生から復旧までの目標時間 |
| RPO | 障害発生時に許容されるデータ損失範囲 |
