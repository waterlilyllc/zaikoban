# Technology Stack

## Architecture

Docker ベースのコンテナ化されたモノリシック Rails アプリケーション。サーバーサイドレンダリング（ERB）+ Tailwind CSS による UI 構築を基本とする。

## Core Technologies

- **Language**: Ruby 3.2.8
- **Framework**: Ruby on Rails 7.1
- **Database**: PostgreSQL 15
- **Cache/Queue**: Redis 7
- **Web Server**: Puma
- **CSS**: Tailwind CSS（MVP 期は CDN 経由、`plugins=forms,container-queries`）
- **Fonts/Icons**: Noto Sans JP（本文）、Material Symbols Outlined（アイコン）

## Key Libraries

- **sprockets-rails**: アセットパイプライン
- **jbuilder**: JSON API レスポンス構築
- **bootsnap**: 起動時間の最適化
- **pg**: PostgreSQL アダプター

## Development Standards

### Code Quality

- Rails 標準の規約に従う（Convention over Configuration）
- MVC パターンの厳守

### UI / Design Tokens

- カラー・角丸・フォントはデザイントークンとして共通化し、ERB 側でのクラス直書きを減らす
- primary / secondary などは Tailwind config（`tailwind.config`）で拡張
- モバイル優先で設計し、PC はブレークポイントで調整

### Testing

- システムテストは生成しない設定（`config.generators.system_tests = nil`）
- debug gem を開発・テスト環境で使用

## Development Environment

### Required Tools

- Docker & Docker Compose
- Ruby 3.2.8（.ruby-version で管理）

### Dockerfile 構成

- **Dockerfile**: 本番用マルチステージビルド（`BUNDLE_WITHOUT=development`、非 root 実行）
- **Dockerfile.dev**: 開発用（WORKDIR=`/app`、バインドマウント前提、bundler/PG client 同梱）

### Common Commands

```bash
# 開発環境起動（web: localhost:3006 → 3000, db: 5436, redis: 6382）
docker-compose up

# コンテナ内で Rails コマンド実行
docker-compose exec web bin/rails <command>

# データベースセットアップ
docker-compose exec web bin/rails db:setup
```

## Key Technical Decisions

- **Docker 優先**: 開発環境は Docker Compose で統一（web / db / redis）
- **PostgreSQL 採用**: データ整合性と拡張性を重視
- **Redis 準備**: Action Cable・キャッシュ・将来のジョブ用に常時起動
- **Tailwind CDN（MVP）**: 初期スピード優先。ビルドパイプライン化は将来検討

---
_Document standards and patterns, not every dependency_
_updated_at: 2026-04-18_
