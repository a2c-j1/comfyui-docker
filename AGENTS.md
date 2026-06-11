# AGENTS

## 概要
- ComfyUI を Docker + Compose で動かす構成。TLS は任意で有効化可能。
- `Dockerfile` で ComfyUI のリリースタグと PyTorch CUDA ベースイメージを固定し、`entrypoint.sh` で証明書があれば HTTPS を有効化。
- データ永続化はホスト側ディレクトリをボリュームマウントして行う。

## 主要ファイル
- `Dockerfile`: ランタイムイメージをビルドし、ComfyUI バージョンを固定。
- `entrypoint.sh`: ComfyUI を起動し、環境変数と証明書の有無で TLS を切り替え。
- `compose.yml` / `compose.yml.example`: ローカルデプロイ用の設定。
- `certs/`: TLS 証明書（自己署名の手順は README 参照）。
- `test/container-structure-test.yaml`: コンテナ構造テストの設定。
- `.github/workflows/container-structure-test.yml`: イメージビルド + 構造テストの CI。
- `scripts/push_ghcr.py`: GHCR へイメージを公開するための補助スクリプト。

## ローカル作業フロー
- ビルド & 起動:
  - `docker compose up --build`
- イメージのみビルド:
  - `docker build -t comfyui-docker:local .`

## 重要な設定値
- 既定ポート: `8188`
- TLS 有効化条件: `TLS_KEYFILE` と `TLS_CERTFILE` の両方がコンテナ内に存在すること
- 主要ボリューム:
  - `./data/*` (ComfyUI のデータ)
  - `./certs` (TLS 証明書)

## テスト
- コンテナ構造テスト（CI と同じ）:
  - `docker build -t comfyui-docker:test .`
  - `docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$(pwd):/workdir" \
      -w /workdir \
      gcr.io/gcp-runtimes/container-structure-test:latest \
      test --image comfyui-docker:test --config test/container-structure-test.yaml`

## 変更時のガイド
- リポジトリ直下 `/home/a2c/deploy/comfyui-docker` は運用用の `main` ブランチを維持し、ここでは直接実装しない。
- 開発作業は `dev` から feature branch を作成し、`git worktree` で別ディレクトリに展開して行う。
- `dev` から `main` への PR をマージした後は、直下の `main` ブランチフォルダで `git pull` して運用ディレクトリを最新化する。
- 複数エージェントで作業する場合、親エージェントはナビゲーターとして改善方針・制約・レビューを担当し、サブエージェントはドライバーとして worktree 内で実装・検証を担当する。
- サブエージェントへ依頼する際は、対象 worktree、変更してよいファイル、使ってよい Docker tag、運用中環境へ触れない条件を明示する。
- feature branch から `dev` への PR は、原則としてナビゲーターがサブエージェントの作業内容をレビューし、作業範囲・検証結果・影響範囲に問題がなければ承認・マージする。
- ただし、運用環境、セキュリティ、CI/CD、永続化データ、Docker/Compose/TLS/GPU runtime などに影響する変更や、ナビゲーターが判断に迷う変更は、`dev` 向け PR であっても人間レビューに回す。
- `dev` から `main` への PR は、運用反映前の最終判断として必ず人間がレビューし、承認後にマージする。
- サブエージェントは作業完了時、ナビゲーターへ PR URL、base/head、コミット SHA、変更ファイル、検証内容、直下 `main` ディレクトリへ触れていないこと、worktree の最終状態、後片付け要否を報告する。
- イメージビルド検証では、運用中の tag / container / compose service を上書きしない別 tag を使う。
- ビルド時間改善の検証は `docker build -t comfyui-docker:<検証用tag> .` のようにイメージビルドだけで行い、`docker compose up` など運用中サービスに影響しうる起動操作は行わない。
- `Dockerfile` を更新したら以下を合わせて更新する:
  - `README.md` / `README_jp.md` の説明
  - `test/container-structure-test.yaml` のバージョン検証
- `compose.yml.example` を更新した場合は `compose.yml` との差分が最小になるよう反映する。
- TLS 周りの挙動を変えた場合は README の手順と `certs/` の例を確認する。

## 注意
- TLS はコンテナ内に `TLS_KEYFILE` と `TLS_CERTFILE` が両方存在する場合のみ有効化。
- データ永続化は `./data/*` と `./certs` のボリュームマウントで行う。
