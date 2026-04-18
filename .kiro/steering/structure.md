# Project Structure

## Organization Philosophy

Rails 標準の MVC アーキテクチャに従った機能別構成。Convention over Configuration の原則を採用。UI はモバイルファーストで、ホーム / 備蓄一覧 / 詳細 / 買い物リスト の画面軸で分割する。

## Directory Patterns

### Application Code (`/app`)

**Location**: `/app/`
**Purpose**: アプリケーションのコアロジック
**Pattern**: Rails 標準 MVC 構造

```
app/
├── assets/       # スタイルシート、JavaScript、画像
├── channels/     # Action Cable チャンネル
├── controllers/  # リクエスト処理
├── helpers/      # ビューヘルパー
├── jobs/         # Active Job バックグラウンドジョブ
├── mailers/      # Action Mailer メール送信
├── models/       # Active Record モデル
└── views/        # ERB テンプレート
```

### Configuration (`/config`)

**Location**: `/config/`
**Purpose**: アプリケーション設定
**Pattern**: 環境別設定ファイル

- `application.rb`: アプリケーション全体設定
- `routes.rb`: ルーティング定義
- `environments/`: 環境別設定（development, test, production）
- `initializers/`: 初期化処理

### Database (`/db`)

**Location**: `/db/`
**Purpose**: データベーススキーマとシード
**Pattern**: マイグレーションベースのスキーマ管理

### Library (`/lib`)

**Location**: `/lib/`
**Purpose**: アプリケーション固有のライブラリ
**Note**: `assets` と `tasks` は autoload から除外

## Domain Model (Planned)

MVP の中心ドメインは備蓄アイテムと収納構造：

- **Item**: 備蓄対象の品目（名前、カテゴリ、写真、メモ）
- **Stock**: Item の在庫レコード（数量、期限、状態）
- **Location / Box**: 収納場所と箱の階層（既存候補サジェストと新規作成に対応）
- **ShoppingListItem**: 買い物リスト項目（Item と連携し、購入で Stock に反映）

関連付け・カラム定義は TICKET-021（モデル定義）および seed（TICKET-022）で具体化する。

## Naming Conventions

- **Models**: 単数形、PascalCase（例: `Item`, `Stock`, `Location`）
- **Controllers**: 複数形、PascalCase + Controller（例: `ItemsController`）
- **Views**: `controller_name/action_name.html.erb`
- **Database Tables**: 複数形、snake_case（例: `items`, `stocks`, `locations`）

## Import Organization

```ruby
# Rails 標準の autoload を使用
# 明示的な require は通常不要

# lib/ 内のカスタムコードは require_relative または autoload 設定で読み込み
```

## Code Organization Principles

- **Fat Model, Skinny Controller**: ビジネスロジックはモデルに集約
- **Concerns**: 共通機能は `app/models/concerns/` や `app/controllers/concerns/` に抽出
- **Service Objects**: 複雑なビジネスロジックは `app/services/` に分離（必要に応じて作成）
- **View 分割**: 画面単位（home / items / shopping）でコントローラと view を対応させ、共通 UI は partial に抽出

---
_Document patterns, not file trees. New files following patterns shouldn't require updates_
_updated_at: 2026-04-18_
