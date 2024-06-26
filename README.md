# Pulsate Development Guide

pulsate-dev/dev-guide は Pulsate の開発方法, 内部実装, 内部設計などを解説した公式開発ガイドです.

このガイドは新しい貢献者の開発を手助けするだけでなく, プロジェクトチームなどのコミュニティメンバーを全員が Pulsate の全貌を理解することを目的としています.

本ガイドの最新版は [`dev-guide.pulsate.dev`](https://dev-guide.pulsate.dev) で閲覧することが出来ます.

またガイドを読む上で [API リファレンス](https://api.pulsate.dev/reference) や [Pulsate の公式ドキュメント](https://docs.pulsate.dev) も合わせて読むことでより理解を深めることができます.

## 本ガイドへのコントリビュート

このガイドの改善にご協力いただける方は [CONTRIBUTING.md](./CONTRIBUTING.md) をご覧ください.

## 本ガイドのビルド手順

本ガイドは [rust-lang/mdbook][mdbook] を使用しています. ビルドなどは [`mdbook`][mdbook] をインストールする必要があります.

Rust を既にインストールしている人は以下のコマンドを実行してください. [(Rust をインストールしていない人は直接バイナリをインストールすることも出来ます.)](https://github.com/rust-lang/mdBook/releases)

```sh
cargo install mdbook
```

各サードパーティプラグインも使用しているため, 同時にインストールしてください.

```sh
cargo install mdbook-toc mdbook-alerts
```

```sh
# ビルド (--open をつけることでブラウザを開く)
mdbook build

# 開発サーバーの起動
mdbook serve
```

本リポジトリには [Makefile](./Makefile) も用意していますので適宜活用してください. (Windows は `Make` を別途インストールする必要があります.)

[mdbook]: https://github.com/rust-lang/mdBook
