# ComfyUI Docker

このリポジトリは、ComfyUI を Docker で動かすための構成です。TLS を利用した HTTPS アクセスにも対応しています。

## 必要環境

- Docker Engine + Docker Compose (v2)
- NVIDIA GPU + NVIDIA Container Toolkit (GPU 利用時)

## サービス構成

- `comfyui`: ComfyUI 本体
- `omgwtfssl`: 自己署名証明書の作成 (一度だけ実行し `./certs` に出力)

## クイックスタート

1) 証明書の生成 (初回のみ、HTTPS を使う場合):

```bash
docker compose run --rm omgwtfssl
```

2) ビルドと起動:

```bash
docker compose up --build
```

3) アクセス:

- https://localhost:8188

## TLS 設定

ComfyUI は以下の環境変数で証明書を参照します。

- `TLS_KEYFILE` (compose 既定: `/app/ComfyUI/certs/servhostname.local.key`)
- `TLS_CERTFILE` (compose 既定: `/app/ComfyUI/certs/servhostname.local.crt`)

両方のファイルが存在する場合は HTTPS、有効でない場合は HTTP で起動します。

## ボリューム

以下のディレクトリがコンテナへマウントされます。

- `./data/custom_nodes`
- `./data/user`
- `./data/models`
- `./data/input`
- `./data/output`
- `./certs`

## 注意点

- HTTPS を使う場合は起動前に `docker compose run --rm omgwtfssl` で
  `./certs` に証明書を用意してください。
