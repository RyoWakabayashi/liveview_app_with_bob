# ElixirPlayground

Elixir初心者向けのインタラクティブなプログラミング学習プラットフォーム

## 🎯 プロジェクト概要

ElixirPlaygroundは、Elixirの基本的な構文や関数の書き方を学べるWebアプリケーションです。ブラウザ上でコードを書いて実行し、即座にフィードバックを得ることができます。

## ✨ 主な機能

- **ユーザー認証**: メール/パスワードによる安全な認証システム
- **演習問題**: 初心者向けの5つの演習問題
  1. 変数と基本演算
  2. 文字列の結合
  3. リストの操作
  4. 無名関数
  5. パターンマッチング
- **コードエディタ**: シンタックスハイライト付きのコードエディタ
- **安全なコード実行**: サンドボックス環境での安全なコード実行
  - タイムアウト制限（5秒）
  - メモリ制限（50MB）
  - 危険な関数の制限
- **進捗管理**: ユーザーごとの学習進捗を追跡
- **リアルタイムフィードバック**: コード実行結果の即座表示

## 🛠️ 技術スタック

- **言語**: Elixir 1.17.3
- **フレームワーク**: Phoenix 1.8.3 with LiveView
- **データベース**: PostgreSQL 16 (Docker)
- **認証**: phx.gen.auth
- **フロントエンド**: TailwindCSS 4.x
- **開発環境管理**: mise

## 📋 前提条件

- [mise](https://mise.jdx.dev/) がインストールされていること
- [Docker](https://www.docker.com/) と Docker Compose がインストールされていること

## 🚀 セットアップ

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd elixir_playground
```

### 2. 開発環境のセットアップ

miseを使用して必要なツールをインストール：

```bash
mise trust
mise install
```

これにより以下がインストールされます：
- Elixir 1.17.3
- Erlang/OTP 27.1.2
- Node.js 22.11.0

### 3. データベースの起動

Docker Composeを使用してPostgreSQLを起動：

```bash
docker compose up -d
```

### 4. 依存関係のインストール

```bash
mix deps.get
```

### 5. データベースのセットアップ

```bash
mix ecto.setup
```

これにより以下が実行されます：
- データベースの作成
- マイグレーションの実行
- シードデータの投入（5つの演習問題）

### 6. アセットのビルド

```bash
mix assets.deploy
```

### 7. 開発サーバーの起動

```bash
mix phx.server
```

アプリケーションは http://localhost:4000 で起動します。

## 📖 使い方

### 1. ユーザー登録

1. http://localhost:4000/users/register にアクセス
2. メールアドレスとパスワードを入力して登録

### 2. 演習問題の選択

1. ログイン後、演習問題一覧ページ（/playground）が表示されます
2. 学習したい演習問題をクリック

### 3. コードの実行

1. コードエディタにElixirコードを入力
2. 「実行」ボタンをクリック
3. 実行結果が右側に表示されます
4. 正解すると「正解です！」のメッセージが表示されます

## 🗂️ プロジェクト構造

```
elixir_playground/
├── lib/
│   ├── elixir_playground/
│   │   ├── accounts/          # ユーザー認証関連
│   │   ├── learning/          # 演習問題とスキーマ
│   │   │   ├── exercise.ex
│   │   │   └── user_progress.ex
│   │   ├── code_executor.ex   # コード実行エンジン
│   │   └── learning.ex        # ビジネスロジック
│   └── elixir_playground_web/
│       ├── live/
│       │   └── playground_live/
│       │       ├── index.ex   # 演習問題一覧
│       │       └── show.ex    # コードエディタ画面
│       └── router.ex
├── priv/
│   └── repo/
│       ├── migrations/        # データベースマイグレーション
│       └── seeds.exs          # 初期データ
├── docker-compose.yml         # PostgreSQL設定
├── .mise.toml                 # 開発環境設定
└── mix.exs                    # プロジェクト依存関係
```

## 🔒 セキュリティ機能

### コード実行の安全性

- **サンドボックス環境**: 各コード実行は独立したプロセスで実行
- **タイムアウト制限**: 5秒以内に実行が完了しない場合は強制終了
- **メモリ制限**: 最大50MBのメモリ使用制限
- **危険な関数の制限**: 以下の関数は使用不可
  - `System.*`
  - `File.*`
  - `:os.*`
  - `spawn`
  - `Code.eval`
  - その他のシステム関連関数

## 🧪 テスト

```bash
mix test
```

## 📝 開発コマンド

```bash
# コンパイル
mix compile

# データベースのリセット
mix ecto.reset

# シードデータの再投入
mix run priv/repo/seeds.exs

# コードフォーマット
mix format

# 静的解析
mix credo

# 依存関係の更新
mix deps.update --all
```

## 🤝 コントリビューション

プルリクエストを歓迎します！大きな変更の場合は、まずissueを開いて変更内容を議論してください。

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 👥 作成者

ElixirPlayground開発チーム

## 🙏 謝辞

- Phoenix Framework
- Elixir コミュニティ
- TailwindCSS

---

Happy Learning! 🎉
