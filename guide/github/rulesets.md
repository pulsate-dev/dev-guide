# Rulesets

> [!NOTE]
>
> このページはプロジェクトチーム向けのガイドです.

<!-- toc -->

## 概要

GitHub には従来よりデフォルトブランチ (一般的には `main` ) に対する保護機能として **Branch Protection Rules** が提供されています. この保護機能は Force Push や CI を通さないマージを防ぐために有効ですが, これらのルールはリポジトリ単位で設定されるため今まではリポジトリ毎に設定を行う必要がありました.

[About protected branches - GitHub Docs](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)

それを改善したのが **Repository rulesets** です. Repository rulesets は GitHub の Organization に対して設定されるルールセットで, JSON ファイル形式での配布も可能です.

Pulsate Project では2024/07/01から順次 Repository rulesets に移行しています.

[About rulesets - GitHub Docs](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)

## Rulesets の適用

> [!IMPORTANT]
>
> リポジトリに対して Rulesets を適用するには Organization の Admin 権限または Maintainer 以上のロールが必要です.

Pulsate Project で使用する Rulesets は [pulsate-dev/rulesets][repo] 配下で管理しています.

[各 Rulesets の概要はこちらから](#pulsate-devrulesets-で管理している-rulesets).

1. [pulsate-dev/rulesets][repo] から適用する Rulesets の JSON ファイルをダウンロードします.
2. Organization の Settings にアクセスします.
3. `Rules` -> `Rulesets` を選択します.
4. `New ruleset` -> `Import ruleset` を選択します.
5. 使用したい Rulesets の JSON ファイルをアップロードします.
6. 設定を確認し, `Save changes` を選択します.

> [!WARNING]
>
> Rulesets には CI などの設定が含まれていないため, CI に関する保護は別途行う必要があります.

[repo]: https://github.com/pulsate-dev/rulesets

## pulsate-dev/rulesets で管理している Rulesets

### 通常版と厳格版の違い

両者の違いは **Bypass 設定** の有無です.

厳格版では `Bypass` 設定が無効化されており, 通常版では有効化されています. 通常版ではコアチーム (Org のオーナー), リポジトリオーナー, Maintainer のみが Bypass を行うことができます.

### Branch Rules

ブランチに対して適用できるルールセットです.

#### Pulsate Default Branch Protection Ruleset

- 通常版: [`rulesets/branches/pulsate-default-branch-protection-ruleset.json`](https://github.com/pulsate-dev/rulesets/blob/main/rulesets/branches/pulsate-default-branch-protection-ruleset.json)
- 厳格版: [`rulesets/branches/pulsate-default-branch-protection-ruleset-strict.json`](https://github.com/pulsate-dev/rulesets/blob/main/rulesets/branches/pulsate-default-branch-protection-ruleset-strict.json)

  - 従来の Branch Protection Rules に準じた設定です.
  - デフォルトブランチに対して動作します.
  - 以下の操作が禁止されます:
    - Force Push
    - Delete

```json
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": ["~DEFAULT_BRANCH"]
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    }
  ],
```

### Tag Rules

タグに対して適用できるルールセットです.

#### Pulsate Tag Protection Ruleset

- 通常版: [`rulesets/tags/pulsate-tag-protection-ruleset.json`](https://github.com/pulsate-dev/rulesets/blob/main/rulesets/tags/pulsate-tag-protection-ruleset.json)
- 厳格版: [`rulesets/tags/pulsate-tag-protection-ruleset-strict.json`](https://github.com/pulsate-dev/rulesets/blob/main/rulesets/tags/pulsate-tag-protection-ruleset-strict.json)

    - すべてのタグに対して動作します.
    - 以下の操作が禁止されます:
      - Force Push
      - Delete
    - タグの署名を必須化します.

```json
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": ["~ALL"]
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "required_signatures"
    }
  ],
```

#### Pulsate Limit Tag Push Protection

[`rulesets/tags/pulsate-limit-tag-push-protection.json`](https://github.com/pulsate-dev/rulesets/blob/main/rulesets/tags/pulsate-limit-tag-push-protection.json)

- タグのプッシュを Org の Owner または Maintainer 以外に制限するルールセットです.
  - すべてのタグに対して動作します.
  - この設定は Org の Owner または Maintainer 以外がタグをプッシュする際にのみ適用されます.
  - 以下の操作が禁止されます:
    - Delete
    - Create
    - Update
    - Force Push
  - タグの署名を必須化します.

```json
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": ["~ALL"]
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "creation"
    },
    {
      "type": "update"
    },
    {
      "type": "required_signatures"
    }
  ],
  "bypass_actors": [
    {
      "actor_id": 5,
      "actor_type": "RepositoryRole",
      "bypass_mode": "always"
    },
    {
      "actor_id": 1,
      "actor_type": "OrganizationAdmin",
      "bypass_mode": "always"
    }
  ]
```
