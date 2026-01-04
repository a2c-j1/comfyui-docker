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

## クライアント側の設定 (自己署名証明書)

自己署名証明書を使う場合、クライアントで `./certs/servhostname.local.crt` を信頼する必要があります。

### Windows (Chrome)

1) `./certs/servhostname.local.crt` をダブルクリック  
2) 「証明書のインストール」→「ローカル コンピューター」  
3) 「証明書をすべて次のストアに配置する」→「信頼されたルート証明機関」  
4) 反映後、Chrome を再起動

### Ubuntu (Chrome)

OS の信頼ストアに追加:

```bash
sudo cp ./certs/servhostname.local.crt /usr/local/share/ca-certificates/comfyui-local.crt
sudo update-ca-certificates
```

もし Chrome で警告が消えない場合は NSS にも追加:

```bash
sudo apt-get install -y libnss3-tools
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "comfyui-local" -i ./certs/servhostname.local.crt
```

### iPad (Safari)

1) `servhostname.local.crt` を iPad に送る (AirDrop など)  
2) 設定 → 一般 → VPN とデバイス管理 → プロファイルをインストール  
3) 設定 → 一般 → 情報 → 証明書信頼設定 で「完全に信頼」を有効化  
4) Safari を再起動

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
