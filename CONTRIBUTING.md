# dev-guide へのコントリビュート

本ガイドの改善にご興味いただきありがとうございます.

改善にご協力いただける方は [Issue](https://github.com/pulsate-dev/dev-guide/issues) をご覧いただき, 重複作業を回避するために取り組む Issue に対してアサインを行ってください. またガイドを読んでいて, 解説を追加してほしいものや修正してほしいものなどがあれば随時 Issue を作成してください.

## ビルド方法

本ガイドは [rust-lang/mdbook][mdbook] を使用しています. ビルドなどは [`mdbook`][mdbook] をインストールする必要があります.

Rust を既にインストールしている人は以下のコマンドを実行してください. [(Rust をインストールしていない人は直接バイナリをインストールすることも出来ます.)](https://github.com/rust-lang/mdBook/releases)

```sh
cargo install mdbook
```

```sh
# ビルド (--open をつけることでブラウザを開く)
mdbook build

# 開発サーバーの起動
mdbook serve
```

本リポジトリには [Makefile](../Makefile) も用意していますので適宜活用してください. (Windows は `Make` を別途インストールする必要があります.)

### サードパーティプラグイン

また目次の生成に [`mdbook-toc`](https://github.com/badboy/mdbook-toc) というサードパーティプラグインを使用しています.

これも `cargo` を使用してインストールしてください.

```sh
cargo install mdbook-toc
```

## 目次の追加

目次が必要な箇所に `<!-- toc -->` マーカーを入れることでプラグインを呼び出すことができます.

## サイドバーの編集

サイドバーは [`./guide/SUMMARY.md`](./guide/SUMMARY.md) で定義されています. 編集する際はこちらを確認してください.

[mdbook]: https://github.com/rust-lang/mdBook
