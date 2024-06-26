# mini-fn

Pulsate では `mini-fn` という関数型プログラミングライブラリを使用しています. ここでは `mini-fn` の基本的な使い方を解説します. 詳しい使い方は[公式ドキュメント][docs]を確認してください.

- GitHub: [`MikuroXina/mini-fn`](https://github.com/MikuroXina/mini-fn)
- ドキュメント: [`mikuroxina.github.io/mini-fn`][docs]

----

<!-- toc -->

## `Option<T>`

- docs: [`Option`](https://mikuroxina.github.io/mini-fn/modules/Option.html)

直接和型 `Option<T>` という型はそれぞれこのような直和型が定義されています:

- 型 `T` が存在するパターンの型: `Some<T>`
- 値が存在しないパターンの型: `None`

この型は `T | undefined` にするか `T | null` にするかどうかを考えずに値を柔軟に扱うことができます. [Rust を書いたことがある場合はすぐに理解することが出来るでしょう](https://doc.rust-lang.org/rust-by-example/std/option.html).

`mini-fn` はこの直接和型と一緒に処理を行うための専用関数を多く提供しています. `null` や `undefined` の値を扱う場合は以下のようなコードを書くことで安全に扱えます.

```ts
// この `res` はアカウントが存在しない可能性があるため, `Option<Account>` という型を持っている
const res = await this.accountRepository.findByName(name);
// `res` に値が存在するかを `isNone()` という型ガードで確認する. 存在していなければエラーを返す
if (Option.isNone(res)) {
  return Result.err(new Error('account not found'));
}
// 値が存在することを確認できたので `unwrap()` で値を確定する. 
const account = Option.unwrap(res);
```

## `Result<T>`

- docs: [`Result`](https://mikuroxina.github.io/mini-fn/modules/Result.html)

[`Option`](#optiont) では値が存在するかどうかを表していました. 同時に値が存在していなかったときにエラーとするエラーハンドリングを行うための直接和型 `Result<T>` は以下のような直和型が定義されています:

- 正常な値: `Ok<T>`
- 対処できるエラー: `Err<E>`

[先ほどの例](#optiont) で出てきたこのコードでは `res` という変数に値が存在していなかったときに `account not found` というエラーを表示しています.

以下の例では取得 (`fetch`) に失敗した際に `Option<T>` の `None` を返している例です:

```ts
// アカウントを取得する関数. アカウント取得に失敗する *可能性* がある.
const account = await this.accountModule.fetchAccount(
    note[1].getAuthorID(),
);

// アカウント取得に失敗したかどうか. 失敗した場合は即座に `None` (アカウントは存在しない) とする.
if (Result.isErr(account)) {
  return Option.none();
}
```

## Ether を用いた依存関係注入の手法

> [!WARNING]
> この節の内容はかなり高度な内容です. 気軽に [Discord](https://link.pulsate.dev/discord) などでご質問をどうぞ.

`mini-fn` には `Ether` で命名した依存関係コンテナの機能がどうにゅうされています. これはオブジェクトや関数が動作するのに必要な依存関係を, 型レベルで表現することで. 型安全に解決しつつ不足物を型エラーで通知することを目的としています.

### シンボルとの対応付けと型情報

`Ether` の仕組みでは, 特定の型定義 (主に `interface`) を型引数に入れて `Ether.newEtherSymbol` を呼び出すことで, Ether 上で扱えるタグ (実態は型情報付きの `Symbol`) をまず生成します.

このやり方で, データベース等による永続化の抽象 (いわゆるレポジトリ), 乱数や通信のような外部のリソース, 意思決定の処理を行う関数 (いわゆるサービス関数) ごとにシンボルを作成しましょう. 型引数に指定した型が同じであっても, シンボルが異なれば別物として扱われます.

例えば,「記事を永続化するレポジトリ `ArticleRepository`」と「意思決定しながら登録のリクエストを処理する関数 `(req: Req) => Promise<void>`」の 2 つをそれぞれ Ether で表すと以下のようになります.

```ts
import { Ether } from "@mikuroxina/mini-fn";

export type Article = {
  createdAt: string;
  updatedAt: string;
  body: string;
};

export interface ArticleRepository {
  has: (id: string) => Promise<boolean>;
  insert: (id: string, article: Partial<Article>) => Promise<void>;
}
export const repoSymbol = Ether.newEtherSymbol<ArticleRepository>();

export type Req = {
  id: string;
  timestamp: string;
  body: string;
};
export const serviceSymbol = Ether.newEtherSymbol<(req: Req) => Promise<void>();
```

### 依存関係の定義と他の依存関係の受け取り

こうして定義したシンボルに対して, それを満たす実際の値を Ether 上で使えるようにしてみましょう. これは `newEther` 関数で行えます. 1 つのシンボルに対して, そのシンボルが担う型 `T` を満たすようなオブジェクト `Ether<D, T>` をいくつもつくることができます.

第 1 引数には紐づける型のシンボルを渡します. そして第 2 引数にはその型のオブジェクトを構築する関数を渡します. この実装により他から依存されるオブジェクトを提供することになります.

オプショナルとなっている第 3 引数は, 欲しい依存関係の名前と, その型に対応するシンボルを辞書のように指定します. 第 2 引数に渡す関数には, 第 3 引数で指定した依存関係が解決されたオブジェクトが渡されます.

```ts
import { Ether } from "@mikuroxina/mini-fn";

export const mockRepository = Ether.newEther(
  repoSymbol,
  () => ({
    has: (id) => Promise.resolve(true),
    insert: (id, article) => Promise.resolve(),
  }),
);

export const service = Ether.newEther(
  serviceSymbol,
  ({ repo }) => async ({ id, timestamp, body }: Req) => {
    if (!await repo.has(id)) {
      return;
    }
    await repo.insert(id, { updatedAt: timestamp, body });
    return;
  },
  { repo: repoSymbol },
);
```

### 依存関係注入のプロセスと駆動できる条件

Ether では必要な依存関係が型引数の情報で表現されています. `Ether<D, T>` 型は, `D` という依存関係たち (変数名とシンボルのキーバリュー型) を使用して, `T` 型のオブジェクトを構築できることを意味します.

Ether モジュールの `compose` 関数を使うことで, ある `Ether` を別の `Ether` へ注入することができます. もしそれが必要な依存関係であれば, 注入先の `D` から注入元のシンボルに対応するものが削られていきます.

```ts
import { Ether } from "@mikuroxina/mini-fn";

// Ether.compose(注入するもの)(注入したい対象) -> 注入された Ether
const injected = Ether.compose(mockRepository)(service);

// 複数を注入するときは Cat が便利です. 関数をどんどん適用できます.
const multiInjcted = Cat.cat(service)
  .feed(Ether.compose(mockRepository))
  .feed(Ether.compose(otherService))
  .feed(Ether.compose(xorShiftRng))
  .value;
```

必要な依存関係がすべてなくなったときだけ, `runEther` 関数でその `T` 型のオブジェクトを取り出すことができます. 依存関係がなくなると, `D` は `Record<string, never>` と同等になります. 逆に, 依存関係がまだ足りない場合は型エラーになって, 不足している依存関係の変数名がエラーに現れます.

```ts
const resolved = Ether.runEther(injected);
```

> [!NOTE]
> 2024 年 5 月 23 日時点の Ether では循環するような依存関係を表現することはできません.

### Promise などのモナド上に依存関係をつくるときは EtherT

この仕組みだけだと, 暗号処理のように依存関係の構築が `Promise` 上でしか行えない場合にうまく両立できなくなります. 構築するオブジェクトが `Promise` に包まれてしまうと, そのまま取り出せず面倒です.

そこで `Ether<D, T>` のモナド変換子 (monad transformer) 版である `EtherT<D, M, T>` の出番です. これは型に包まれている依存関係の解決を, モナドの力で包まれていることを気にせずに扱えるようにします.

例として `Promise` 上で構築する場合の説明をします. `newEtherT` 関数と `runEtherT` 関数は, `Ether` 用のものと全く使い方が変わりません.

```ts
import { Ether, Promise } from "@mikuroxina/mini-fn";

export const authenticateTokenSymbol =
  Ether.newEtherSymbol<AuthenticationTokenService>();
export const authenticateToken = Ether.newEtherT<Promise.PromiseHkt>()(
  authenticateTokenSymbol,
  AuthenticationTokenService.new,
);
```

依存関係を注入する `composeT` だけは異なり, 引数としてモナドを要求するようになっています. `Promise` 上で依存関係を注入するときは, そのモナドを指定することになります. さらに通常の `Ether` と `EtherT` を混ぜる際には, `Ether` 側の方を `liftEther` 関数で同じタイプの `EtherT` に変換してやる必要があります.

```ts
import { Ether, Promise } from "@mikuroxina/mini-fn";

const composer = Ether.composeT(Promise.monad);
const liftOverPromise = Ether.liftEther(Promise.monad);

const authenticateService = await Ether.runEtherT(
  Cat.cat(liftOverPromise(authenticate))
    .feed(composer(liftOverPromise(accountRepository)))
    .feed(composer(authenticateToken))
    .feed(composer(liftOverPromise(argon2idPasswordEncoder))).value,
);
```

> [!NOTE]
> 2024 年 5 月 23 日時点で `liftEther` 関数を追加しているバージョンはまだリリースされていません. そのためアカウント API の実装では `lift` 処理を自前で実装しています.

----

ここまでで出てきた使い方を箇条書きでまとめます.

- `interface` などで作った型に対して, 対応するシンボルを `newEtherSymbol` で構築する.
- `newEther` でシンボルの型に対応する `Ether` オブジェクトを構築する.
- `compose` で特定の `Ether` に他の `Ether` たちを注入する. これは `Cat` を少し使うと楽になる.
- `runEther` で注入し終わった `Ether` の構築処理を実行する.
- 構築処理で `Promise` などが必要な場合は, うしろに `T` がついているモノを利用する.

[docs]: https://mikuroxina.github.io/mini-fn/
