# 開発に参加する

このページでは Pulsate Project の開発に参加するための基本的な準備について説明します.

<!-- toc -->

## 開発環境の構築

Pulsate Project では基本的な開発環境として Node.js と pnpm を使用します. また Node.js のバージョン管理には mise (または asdf) を使用します.

### Node.js のインストール・バージョン管理

Node.js のインストール, バージョン管理には以下のツールを使用します.

- [mise](https://mise.jdx.dev/): 推奨
  - 独自ファイルのほか `.tool-versions` などとの互換性あり.
- asdf

> [!TIP]
>
> **とくに理由がない限りは mise を使用することを推奨しています**. ただし主要プロジェクトでは `.tool-versions` を使用し, asdf との互換性を保つようにしています.

Pulsate の設計思想上 セキュリティや互換性の問題がない限り, **Pulsate Project では原則 Node.js は LTS バージョンを使用します**. プロジェクトディレクトリ上で実行すると自動で Node.js のバージョンが切り替わるようになっています.

```sh
# プロジェクト内のディレクトリで
mise install
```

### pnpm のインストール

Pulsate Project では pnpm を使用します. pnpm は Corepack を使用してインストールします. プロジェクト指定の pnpm では各スクリプトなどを実行できないため, 以下のコマンドを使用してインストールしてください.

```sh
corepack enable pnpm
pnpm install

# グローバルインストールは不適切です. 使用しないことを強く推奨します. Pulsate Project では使用しないでください.
npm install -g pnpm
```

> [!WARNING]
>
> そのプロジェクトが使用している Node.js や pnpm のバージョンと貴方の環境が異なる場合, pnpm のコマンドなどは実行できないような設計を行っています. エラーが発生した場合は mise を使用し Node.js のバージョンを合わせてください.

## エディター (IDE) の選択

Pulsate Project ではエディターとして Visual Studio Code を推奨しています. 自己責任とはなりますが, 他のエディターや IDE を使用しても問題ありません.

- [Visual Studio Code](https://code.visualstudio.com/) (推奨)
- [WebStorm](https://www.jetbrains.com/webstorm/)
  - [IntelliJ IDEA](https://www.jetbrains.com/idea/)
- [Zed](https://zed.dev/) (macOS のみ)
- [Vim](https://www.vim.org/)

など
