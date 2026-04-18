# Research & Gap Analysis — home-layout

## Summary
- **Feature**: `home-layout`
- **Discovery Scope**: New Feature（Rails 新規アプリにゼロから追加）
- **Key Findings**:
  - 既存コードはほぼ Rails 7.1 の雛形のみ。`routes.rb` は health check のみ、`app/controllers` / `app/views` にホーム実装は無い。
  - `test/` ディレクトリ自体が未生成。Minitest（Rails 既定）で新規にセットアップが必要。
  - `application.html.erb` は Rails 生成直後の状態で、`<title>App</title>` / 基本 viewport / CSRF/CSP / sprockets の `stylesheet_link_tag "application"` のみ。Tailwind や Google Fonts の読み込みは未設定。
  - RSpec / Capybara 等のテスト拡張 gem は Gemfile に無い → 追加せず Minitest に統一が自然。
  - Sprockets は既に入っているが、Tailwind は TICKET-002 まで CDN 運用で問題なし。

---

## Requirement-to-Asset Map

| Req | 要件概要 | 既存資産 | ギャップ | 分類 |
|---|---|---|---|---|
| Req 1 | `/` → `home#index`、health check 維持 | `config/routes.rb`（`get "up"` のみ） | `root "home#index"` 追加 / `HomeController` 新規 | Missing |
| Req 2 | 静的レイアウト・partial 分割 | `app/views/layouts/application.html.erb`（雛形） | `app/views/home/index.html.erb` と partial 群を新規作成 | Missing |
| Req 3 | Noto Sans JP / Plus Jakarta Sans / Material Symbols 読込 | `application.html.erb` に `<link>` 無し | `<link rel="stylesheet">` 3 本を `<head>` に追加 | Missing |
| Req 4 | Tailwind CDN + インライン `tailwind.config`（primary/secondary） | Tailwind 未導入 | `<script>` で CDN + インライン config を追加 | Missing |
| Req 5 | モバイルファースト（viewport、375px 崩れ無し） | viewport meta は存在 | `<html class="light">`、コンテナクラス（`max-w-md mx-auto` 相当） | Partial |
| Req 6 | `lang="ja"`・`<meta charset>`・タイトル・CSRF/CSP | charset は暗黙、CSRF/CSP は erb ヘルパ済 | `<html lang="ja" class="light">`、`<title>在庫番 - ホーム</title>` に差し替え | Partial |
| Req 7 | JS / サーバーエラー無し、フォールバック表示 | Rails 標準挙動 | 特段の追加実装不要 | Covered |
| Req 8 | スコープ境界（仮データ・導線・モデル・最適化は他チケット） | — | 実装側で「やらない」統制 | Governance |
| Req 9 | request spec で 200・タイトル・主要ブロック検証 | `test/` 未生成 | `test/controllers/home_controller_test.rb` を新規作成、`test/test_helper.rb` 等の Rails 既定ツリー生成 | Missing |
| Req 10 | FIX HTML 完全版の入手 | Issue 本文は省略 | 実装前にユーザーから提供、または仮骨格で合意形成 | Unknown（Research Needed） |

### 既存コンベンション（抽出）
- 命名: Rails 標準 CoC（`controller_name_controller.rb` → `app/views/controller_name/action.html.erb`）
- レイアウト: `application.html.erb` を全画面共通（まだ他レイアウト無し）
- テスト配置: Rails 既定は `test/{controllers,integration,models,…}/`。本プロジェクトでは未生成
- 設定: `config.generators.system_tests = nil`（システムテスト生成無し）— 維持

### 統合面
- **CSS 競合**: sprockets の `application.css` は空同然（`require_tree .` + `require_self` のみ）。Tailwind CDN と併存しても衝突リスク低。レイアウトから `stylesheet_link_tag` を外すかは設計判断（Option の評価ポイント）。
- **外部リソース**: Tailwind CDN / Google Fonts への依存。オフライン開発時の挙動は Req 7 の AC3（フォールバック）でカバー。
- **Content Security Policy**: `config/initializers/content_security_policy.rb` は既定でコメントアウト中。CDN 利用のため、有効化された際に `script-src`/`style-src`/`font-src` の追加が必要（本チケットでは発動しないが設計で言及）。

---

## Implementation Approach Options

### Option A: 既存 `application.html.erb` を更新 + `HomeController` / `home/index` を新規追加
**概要**: Rails 標準の MVC 最短パスで追加。レイアウトは全画面共通のまま、Tailwind / Fonts / HTML 属性をここに集約。

- **変更**: `config/routes.rb`, `app/views/layouts/application.html.erb`
- **新規**: `app/controllers/home_controller.rb`, `app/views/home/index.html.erb`, `app/views/home/_*.html.erb`（partial 4 種目安）, `test/` 配下

**Trade-offs**:
- ✅ 最短、Rails 規約通り、認知負荷小
- ✅ 他チケット（他画面が増えるまで）までは十分
- ❌ 後で画面ごとに異なる `<head>`（例：ログインページで Tailwind 不要等）にしたくなった場合、再分割コストが発生

### Option B: 新規レイアウト `app/views/layouts/home.html.erb` を作成し、`HomeController` で指定
**概要**: home 専用レイアウトに Tailwind/Fonts を載せ、`application.html.erb` は将来のため温存。

- **変更**: `config/routes.rb`
- **新規**: `home.html.erb`, `HomeController`, `home/index.html.erb`, partials, `test/` 配下

**Trade-offs**:
- ✅ 他画面との分離が容易
- ❌ 備蓄一覧 / 詳細 / 買い物も同系統のデザインになるため、層の重複が生じる可能性高
- ❌ 本 MVP のスコープでは YAGNI

### Option C: `tailwindcss-rails` gem でビルド統合（スコープ外）
**概要**: CDN でなくビルド統合。CSP 適用・本番安定・purging のメリット。

- **変更**: `Gemfile`, `config/` 複数、Dockerfile の node 導入
- **新規**: `tailwind.config.js`, `app/assets/tailwind/application.css` など

**Trade-offs**:
- ✅ 本番品質
- ❌ TICKET-001 のスコープを明確に超える（TICKET-002 で検討）
- ❌ Node toolchain 導入で Docker 環境の再設計が必要

---

## Architecture Pattern Evaluation

| Option | 説明 | 長所 | 短所 / リスク | 備考 |
|---|---|---|---|---|
| A (共通 layout 更新) | 既存 `application.html.erb` を育てる | 最短・規約通り | 将来の画面差別化で再編の可能性 | **推奨** |
| B (home 専用 layout) | 画面別 layout で分離 | 影響局所化 | 他画面で重複増・YAGNI | 却下 |
| C (tailwind-rails 統合) | ビルドパイプ化 | 本番品質 | スコープ超過 | TICKET-002 で検討 |

---

## Design Decisions（引き継ぎ事項）

### Decision 1: Minitest を採用
- **Context**: `test/` 未生成、RSpec 未導入。Rails 既定に沿うか別 gem を入れるか
- **選択**: Minitest + Integration / Request Test
- **Rationale**: 既定・最小依存。request spec で `GET /` のステータス / タイトル / 主要ブロックを検証可能
- **Trade-offs**: 記述が RSpec より冗長。ただし小規模で許容

### Decision 2: partial 分割の粒度
- **Context**: 拡張性 vs 過分割
- **選択**: `_header.html.erb` / `_summary.html.erb` / `_actions.html.erb` / `_bottom_nav.html.erb` の 4 partial（FIX HTML の論理ブロックに対応）
- **Rationale**: 後続の TICKET-003（仮データ）/ 004（導線）で「どの partial に差し込むか」が自明になる
- **Trade-offs**: FIX HTML の構造次第で増減する可能性あり → 設計時に確定

### Decision 3: Tailwind はインライン config、sprockets application.css は残す
- **Context**: Tailwind CDN 採用、既存 sprockets 残存
- **選択**: `application.html.erb` から `<script>` で CDN + インライン `tailwind.config` を注入。`stylesheet_link_tag "application"` は**削除**（空のため不要・Tailwind と干渉しない設計）
- **Rationale**: 不要な CSS を読まない、Tailwind の優先度を明示
- **Trade-offs**: 将来 CSS を書く際に sprockets を使うか Tailwind の `@apply` にするかの判断が必要 → TICKET-002

### Decision 4: `data-testid` 属性でテスト安定性を確保
- **Context**: Req 9 で主要ブロックの検証が必要
- **選択**: `_header` / `_summary` / `_actions` / `_bottom_nav` の最外殻要素に `data-testid="home-header"` 等を付与
- **Rationale**: CSS クラス変更に対してテストが壊れない
- **Trade-offs**: HTML がわずかに冗長 → 受容

---

## Complexity & Risk

- **Effort**: **S (1–3 日)** — Rails 雛形追加のみ、外部依存は CDN 2 本、既存パターン踏襲
- **Risk**: **Low** — 既存資産と衝突する領域なし、Rails 標準の挙動、CDN 利用はフォールバックで担保

---

## Risks & Mitigations
- **FIX HTML の `<body>` 完全版未提供**: 着手前にユーザーへ依頼、未提供時は仮骨格（4 partial にダミーテキスト）で合意形成
- **CDN 依存での CSP 競合**: 本チケットでは CSP 初期化子が未有効化のため問題にならないが、設計 doc に「将来 CSP 有効化時の対応案」を明記
- **sprockets の `application.css` を削除した場合の副作用**: 空 manifest だが他画面が未作成のため現時点で無影響。レイアウト側で link_tag 削除のみで足りる

---

## Research Needed（設計フェーズで確定）
- FIX HTML 完全版の `<body>` 内部構造（partial 分割の最終確定に必要）
- Rails 7.1 の Minitest 雛形生成方針（`bin/rails g controller home index` の `--no-test-framework` の可否、または手書きで作成）
- Material Symbols の `wght,FILL@100..700,0..1` 指定を Tailwind の `font-variation-settings` でどう当てるか
- 本番向け CSP ポリシーの想定（将来 TICKET で対応）

---

## References
- Rails 7.1 Routing Guide — https://guides.rubyonrails.org/routing.html
- Rails Minitest Testing — https://guides.rubyonrails.org/testing.html
- Tailwind CSS CDN — https://tailwindcss.com/docs/installation/play-cdn
- Google Fonts (Material Symbols) — https://fonts.google.com/icons
- Steering: `.kiro/steering/{product,tech,structure}.md`
