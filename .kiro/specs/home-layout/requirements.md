# Requirements Document

## Project Description (Input)
TICKET-001 ホーム画面の基本レイアウトを実装する。Rails 7.1 + Tailwind CSS（CDN）で、FIX HTML をベースにした在庫番アプリのホーム画面を `/` に実装する。モバイルファースト、primary=#335278 / secondary=#48654c、Noto Sans JP + Plus Jakarta Sans + Material Symbols Outlined を使用。対象は静的レイアウトのみで、仮データ表示(TICKET-003)・導線接続(TICKET-004)・デザイントークン厳密化(TICKET-002)はスコープ外。TDD + SDD 方針で進める。GitHub Issue #3 に対応。feature name 候補: home-layout

## Introduction

本仕様は、在庫番（Zaikoban）アプリのホーム画面（`/`）の静的な基本レイアウトを Rails 7.1 アプリに実装するための要件を定義する。実装の基準は GitHub Issue #3（TICKET-001）に添付された FIX HTML であり、そこに含まれる Tailwind CSS クラス・カラー・タイポグラフィ・アイコンを尊重しつつ、Rails の MVC / ERB / レイアウト・partial 構造に分解して落とし込む。

本チケットは MVP の入口に位置し、以下の後続チケットの前提となる：

- TICKET-002（デザイントークン厳密化）
- TICKET-003（仮データ表示）
- TICKET-004（ホーム導線の仮接続）
- TICKET-023 / 024（スマホ・PC 最適化）

よって、本チケットの要件は「壊れずに表示できること」「拡張に耐える partial 構造になっていること」を中心とし、動的データ・対話動作・最適化は意図的にスコープ外とする。

## Requirements

### Requirement 1: ルートルーティング
**Objective:** 在庫番アプリの利用者として、アプリのルート URL (`/`) にアクセスしたい、なぜならホーム画面を最初の画面として確認するためである

#### Acceptance Criteria
1. The Rails application shall ルート URL `/` を `HomeController#index` に割り当てる。
2. When 利用者が `/` に GET リクエストを送る, the Rails application shall HTTP ステータス 200 で応答する。
3. When 利用者が `/` に GET リクエストを送る, the Rails application shall `home/index.html.erb` をレンダリングする。
4. The Rails application shall 既存の `get "up" => "rails/health#show"`（health check）ルートを維持する。
5. If ルート URL 以外の未定義パスに GET リクエストが来る, then the Rails application shall 既定の 404 / ルーティングエラー挙動を維持する（本チケットでは変更しない）。

### Requirement 2: ホーム画面の静的レイアウト
**Objective:** 在庫番アプリの利用者として、FIX HTML に準拠したホーム画面のレイアウトを見たい、なぜならデザイン仕様通りの UI を確認するためである

#### Acceptance Criteria
1. When ホーム画面がレンダリングされる, the Home view shall FIX HTML で定義された主要ブロック（画面ヘッダー / サマリー領域 / 主要アクション導線 / ボトムナビ）をすべて描画する。
2. The Home view shall レイアウトとして `app/views/layouts/application.html.erb` を使用する。
3. The Home view shall 画面構成要素を `app/views/home/` 配下の partial（例: `_header.html.erb`, `_summary.html.erb`, `_actions.html.erb`, `_bottom_nav.html.erb`）に分割して組み合わせる。
4. Where 後続チケット（TICKET-003 / 004 など）で動的データや導線が追加される, the Home view shall 現行の partial 分割と命名を崩さずに拡張できる構造を維持する。
5. The Home view shall FIX HTML の `<body>` 構造と視覚的に同等の DOM 構造を持つ。

### Requirement 3: タイポグラフィとアイコン読込
**Objective:** 在庫番アプリの利用者として、指定のフォントとアイコンで描画されたホーム画面を見たい、なぜならデザインの統一性と可読性を保つためである

#### Acceptance Criteria
1. When ホーム画面が読み込まれる, the application layout shall Google Fonts 経由で Noto Sans JP（weights: 400, 500, 700）を読み込む。
2. When ホーム画面が読み込まれる, the application layout shall Google Fonts 経由で Plus Jakarta Sans（weights: 400, 500, 600, 700, 800）を読み込む。
3. When ホーム画面が読み込まれる, the application layout shall Google Fonts 経由で Material Symbols Outlined（variable: wght, FILL）を読み込む。
4. The Home view shall 本文テキストに Noto Sans JP を適用する。
5. The Home view shall 見出し系テキストに Plus Jakarta Sans を適用できる（FIX HTML の指定に従う）。
6. The Home view shall アイコン要素に Material Symbols Outlined クラスを適用する。

### Requirement 4: カラーと Tailwind 設定（初期値）
**Objective:** 開発者として、FIX HTML で定義された primary / secondary カラーをホーム画面に適用したい、なぜなら後続のデザイントークン厳密化 (TICKET-002) の基礎となるためである

#### Acceptance Criteria
1. The application layout shall Tailwind CDN `https://cdn.tailwindcss.com?plugins=forms,container-queries` を `<script>` タグで読み込む。
2. The application layout shall インラインの `tailwind.config` スクリプトで `theme.extend.colors.primary = "#335278"` と `theme.extend.colors.secondary = "#48654c"` を定義する。
3. The application layout shall インラインの `tailwind.config` で `darkMode: "class"` を設定する。
4. The Home view shall primary / secondary の Tailwind クラス（例: `bg-primary`, `text-secondary` など）を FIX HTML の指定箇所で使用する。
5. Where TICKET-002 でデザイントークンの厳密化が行われる, the application layout shall 現行のインライン設定を容易に置換できるようコメントまたは分離された `<script>` ブロックで管理する。

### Requirement 5: モバイルファースト表示
**Objective:** スマートフォン利用者として、iPhone 幅（約 375px）でホーム画面が視覚的に崩れず表示されたい、なぜならモバイル操作が主要な利用シーンであるためである

#### Acceptance Criteria
1. The application layout shall `<meta name="viewport" content="width=device-width, initial-scale=1.0">` を含む。
2. When ブラウザが幅 375px で表示する, the Home view shall 主要ブロックが画面内に収まり、水平スクロールを発生させない。
3. When ブラウザが幅 1280px で表示する, the Home view shall 要素の重なりや大きな崩れを起こさず表示する。
4. The Home view shall モバイルファーストのコンテナ設計として、中央寄せの幅制約（FIX HTML の指示に従う。例: `max-w-md mx-auto` 相当）を使用する。
5. Where PC 幅特有の最適化が求められる, the Home view shall その詳細対応を TICKET-024 に委ねる（本チケットでは致命的崩れがないレベルまで）。

### Requirement 6: HTML / HEAD の基本属性
**Objective:** 利用者および検索エンジンとして、日本語コンテンツとして正しく認識されるホーム画面が欲しい、なぜなら正しい言語判定とタブ表示のためである

#### Acceptance Criteria
1. The application layout shall `<html lang="ja">` を設定する。
2. The application layout shall `<html class="light">` を設定する（FIX HTML の `darkMode: "class"` との整合のため）。
3. The application layout shall `<meta charset="utf-8">` を設定する。
4. The application layout shall ブラウザタブのタイトルに `在庫番 - ホーム` を設定する（ホーム画面表示時）。
5. The application layout shall `csrf_meta_tags` / `csp_meta_tag` など Rails 既定のメタタグを維持する。

### Requirement 7: エラーのない表示
**Objective:** 開発者として、ホーム画面の表示時にエラーが出ないことを保証したい、なぜなら MVP の入口でのユーザー体験とデバッグ効率のためである

#### Acceptance Criteria
1. When ホーム画面を最新版 Chrome で表示する, the Home view shall JavaScript エラーをブラウザコンソールに出力しない。
2. When ホーム画面を読み込む, the Rails application shall サーバーログに `ERROR` レベル以上のログを出力しない。
3. If Tailwind CDN または Google Fonts の外部リソースが取得できない, then the Home view shall ページ自体の 200 応答を維持し、最低限のテキスト読取を可能にする（フォールバック表示）。

### Requirement 8: スコープ境界（除外事項）
**Objective:** プロジェクト管理者として、本チケットのスコープを明示したい、なぜなら後続チケットとの重複や漏れを防ぐためである

#### Acceptance Criteria
1. The Home view shall 備蓄アイテムなどの仮データ表示を含まない（TICKET-003 のスコープ）。
2. The Home view shall 要素タップ時の画面遷移やフォーム送信などの導線処理を含まない（TICKET-004 のスコープ）。
3. The application layout shall Tailwind config のデザイントークン厳密化（カスタム値の partial 化・CSS 変数化など）を含まない（TICKET-002 のスコープ）。
4. The Home view shall スマホ固有の細部最適化を含まない（TICKET-023 のスコープ）。
5. The Home view shall PC 幅での詳細調整を含まない（TICKET-024 のスコープ）。
6. The Rails application shall Item / Stock / Location などの Active Record モデル実装を含まない（TICKET-021 のスコープ）。

### Requirement 9: テスト可能性（TDD 前提）
**Objective:** 開発者として、TDD サイクルで自動検証可能な成果物にしたい、なぜなら回帰防止と設計の健全性を保つためである

#### Acceptance Criteria
1. The Rails application shall `GET /` を対象とした request spec（Minitest または RSpec）で HTTP 200 応答を検証できる。
2. When request spec が `GET /` を実行する, the Home view shall レスポンスボディに文字列 `在庫番 - ホーム` を含める。
3. When request spec が `GET /` を実行する, the Home view shall 主要ブロックを示す識別可能な要素（例: `data-testid="home-header"` 等の属性、または安定した CSS セレクタ）を含める。
4. The Rails application shall ルーティングテストで `root "home#index"` を検証できる状態とする。
5. The Rails application shall 追加するテストを Rails 既定のテストディレクトリ構成（`test/` 配下）に配置する（`config.generators.system_tests = nil` の方針は維持し、システムテストは生成しない）。

### Requirement 10: 前提条件（FIX HTML の提供）
**Objective:** 実装者として、実装基準となる FIX HTML の完全版が必要である、なぜなら GitHub Issue #3 本文では `<body>` 内部が省略されているためである

#### Acceptance Criteria
1. The project stakeholder shall 実装着手前に FIX HTML の完全版（`<body>` 内部含む）を Issue コメントまたは添付で提供する。
2. If FIX HTML の完全版が未提供である, then the implementation team shall 実装を保留し、代替としてプレースホルダ（空のヘッダー / サマリー / アクション / ボトムナビ）で仮骨格のみを構築する判断を行う。
3. The Home view shall 提供された FIX HTML と視覚的に同等（見た目の崩れがない）であることを目視で確認できる。
