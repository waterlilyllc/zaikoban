# Implementation Plan

> 進め方: **TDD 厳守**。各 sub-task は明示されていない限り Red（失敗テスト先行）→ Green（最小実装）→ Refactor の順に進める。FIX HTML 完全版が未提供の場合は Mode B（仮骨格）で進める（design.md 参照）。

- [x] 1. テスト基盤セットアップ
- [x] 1.1 Minitest のテストツリーを作成する
  - `test/` ディレクトリと `test/test_helper.rb`（Rails 7.1 既定内容）を新規に作成する
  - `test/controllers/` ディレクトリを作成する
  - `docker-compose exec web bin/rails test` が「テスト 0 件」で正常終了することを確認する
  - _Requirements: 9.5_

- [x] 2. ルートルーティングを TDD で確立する
- [x] 2.1 ルート割当の routing テストを Red で追加する
  - `/` を GET したときに `home#index` に解決されることを検証するアサーションを追加する
  - 合わせて既存 health check（`/up`）が維持されていることも検証する
  - 実装未着手のため `test` 実行で失敗することを確認する（Red）
  - _Requirements: 1.1, 1.4, 9.4_
- [x] 2.2 `root "home#index"` を routes に追加し Green にする
  - ルート定義を追加しつつ health check ルートを維持する
  - 本サブタスク時点ではコントローラ未実装のため request テストは別サブタスクで扱う
  - _Requirements: 1.1, 1.4_

- [x] 3. HomeController と index view の最小実装（TDD）
- [x] 3.1 `GET /` の 200 応答を検証する request テストを Red で追加する
  - レスポンスステータスと Content-Type を検証するアサーションを追加する
  - HomeController 未実装のため失敗することを確認する（Red）
  - _Requirements: 1.2, 9.1_
- [x] 3.2 `HomeController#index` と空の `home/index.html.erb` を作成し Green にする
  - コントローラは副作用・インスタンス変数を持たない最小実装とする
  - index view は空で構わない（後続で partial を合成）
  - テスト 3.1 が通ることを確認する
  - _Requirements: 1.2, 1.3_

- [x] 4. 共通レイアウトを FIX HTML の `<head>` 仕様に合わせる（TDD）
- [x] 4.1 レイアウト要件のテストを Red で追加する
  - タイトルが `在庫番 - ホーム` であることのアサーション
  - Tailwind CDN の `<script>` が読み込まれていることのアサーション
  - Google Fonts の Noto Sans JP / Plus Jakarta Sans / Material Symbols Outlined の `<link>` が読み込まれていることのアサーション
  - `<body>` に `font-sans` クラスが適用されていることのアサーション
  - `<html lang="ja" class="light">` および `<meta charset="utf-8">` / viewport のアサーション
  - CSRF / CSP ヘルパの出力が維持されていることのアサーション
  - 既存の最小レイアウト下では失敗することを確認する（Red）
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.5, 5.1, 6.1, 6.2, 6.3, 6.4, 6.5, 9.2_
- [x] 4.2 `application.html.erb` を書き換えて Green にする
  - `<html>` / `<head>` を FIX HTML 仕様に準拠させる
  - インライン `tailwind.config` に `primary`/`secondary` カラーと `fontFamily.sans`/`fontFamily.display` を拡張する
  - `darkMode: "class"` を設定する
  - sprockets の `stylesheet_link_tag "application"` をレイアウトから除去する
  - Google Fonts 2 ドメインへの `preconnect` を追加する
  - テスト 4.1 が通ることを確認する
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 5. Partial 分割でホーム本体を組み立てる（TDD）
- [x] 5.1 主要ブロック存在テストを Red で追加する
  - `data-testid` 属性で `home-root`（index 最外殻コンテナ）、`home-header`、`home-summary`、`home-actions`、`home-bottom-nav` がそれぞれ存在することのアサーション
  - コンテナに `max-w-md mx-auto` 相当のクラスが当たっていることのアサーション（Req 5.4）
  - 未実装のため失敗することを確認する（Red）
  - _Requirements: 2.1, 2.3, 2.5, 5.4, 9.3_
- [x] 5.2 4 つの partial（`_header` / `_summary` / `_actions` / `_bottom_nav`）を作成する
  - 各 partial 最外殻に対応する `data-testid` を付与する
  - FIX HTML 完全版がある場合はその内容に忠実に移植する（Mode A）
  - 未提供なら `<section>` / `<nav>` にテキストプレースホルダのみ配置する（Mode B）
  - `_bottom_nav.html.erb` の `<nav>` には `aria-label="メインナビゲーション"` を付与する
  - アイコン要素は `material-symbols-outlined` クラスを使用する
  - _Requirements: 2.1, 2.3, 2.5, 3.5, 3.6_
- [x] 5.3 `home/index.html.erb` で partial を合成し Green にする
  - 最外殻を `<main data-testid="home-root" class="max-w-md mx-auto ...">` 相当で構成する
  - partial を header → summary → actions → bottom_nav の順でレンダリングする
  - テスト 5.1 が通ることを確認する
  - _Requirements: 2.1, 2.2, 2.4, 5.4_

- [x] 6. リファクタと視覚・DoD 確認
- [x] 6.1 テスト全体を再実行し Green を維持しながら冗長記述を整理する
  - レイアウトや partial の重複クラス・不要な `style` をまとめる
  - 視覚的な崩れが出ないことを `docker-compose up` の目視で確認する
  - _Requirements: 2.4, 5.2, 5.3_
- [x] 6.2 手動 DoD を実行し記録する
  - M1: iPhone 375px / PC 1280px でレイアウト崩れが無いことを確認する（Req 5.2, 5.3）
  - M2: Tailwind CDN をブロックしても 200 応答・本文可読であることを確認する（Req 7.3）
  - M3: Google Fonts をブロックしても 200 応答・本文可読であることを確認する（Req 7.3）
  - M4: ブラウザコンソールに JS エラーが出ないことを確認する（Req 7.1）
  - サーバーログに `ERROR` レベル以上の出力がないことを確認する（Req 7.2）
  - 未定義パス（例: `/not-found`）で既定 404 応答が維持されていることを確認する（Req 1.5）
  - _Requirements: 5.2, 5.3, 7.1, 7.2, 7.3, 1.5_

- [x] 7. スコープ境界の最終確認（governance）
- [x] 7.1 スコープ外の実装が紛れ込んでいないことを差分で確認する
  - 仮データ・導線・トークン厳密化・最適化・ドメインモデルなどが本 PR の差分に含まれていないこと
  - FIX HTML の扱いモード（A/B）を Issue コメントまたは PR 説明に明記する
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 10.1, 10.2, 10.3_
