# ComfyUI Docker

このリポジトリは、ComfyUI を Docker で動かすための構成です。TLS を利用した HTTPS アクセスにも対応しています。

## 必要環境

- Docker Engine + Docker Compose (v2)
- NVIDIA GPU + NVIDIA Container Toolkit (GPU 利用時)

## サービス構成

- `comfyui`: ComfyUI 本体

## このイメージで有効になる機能

- ComfyUI `v0.8.2`（リリースタグ固定）
- ComfyUI Manager を有効化（`--enable-manager`）
- CUDA 対応 PyTorch ランタイム（GPU 利用には NVIDIA GPU が必要）
- `TLS_KEYFILE` / `TLS_CERTFILE` があれば HTTPS/TLS を有効化
- ボリュームマウントでデータ永続化（`./data/*`, `./certs`）

## クイックスタート

1) 証明書の生成 (初回のみ、HTTPS を使う場合):

```bash
cp certs/san.conf.example certs/san.conf
```

`certs/san.conf` をサーバー環境に合わせて編集 (例: `DNS.1` / `IP.1` を実際のホスト名・IP に変更) します。

```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
  -keyout certs/key.pem -out certs/cert.pem \
  -config certs/san.conf -extensions req_ext
```

2) compose ファイルの作成:

```bash
cp compose.yml.example compose.yml
```

3) (任意) `compose.yml` を環境に合わせて調整:

- `ports` を変更（8188 が使用中の場合）
- TLS 環境変数をコメントアウトして HTTP 強制
- `CUDA_VISIBLE_DEVICES` で使用GPUを制限

4) ビルドと起動:

```bash
docker compose up --build
```

5) アクセス:

- https://localhost:8188

## Container Registry (GHCR)

GHCR に public イメージを公開しています。

- イメージ: `ghcr.io/a2c-j1/comfyui`
- タグ: `latest`, `v0.8.2`

例:

```bash
docker pull ghcr.io/a2c-j1/comfyui:latest
```

## TLS 設定

ComfyUI は以下の環境変数で証明書を参照します。

- `TLS_KEYFILE` (compose 既定: `/app/ComfyUI/certs/key.pem`)
- `TLS_CERTFILE` (compose 既定: `/app/ComfyUI/certs/cert.pem`)

両方のファイルが存在する場合は HTTPS、有効でない場合は HTTP で起動します。

## 環境変数

必須:

- なし

任意:

- `TLS_KEYFILE` / `TLS_CERTFILE`（両方が存在する場合に HTTPS を有効化）
- `CUDA_VISIBLE_DEVICES`（使用GPUを制限）

## クライアント側の設定 (自己署名証明書)

自己署名証明書を使う場合、クライアントで `./certs/cert.pem` を信頼する必要があります。

### Windows (Chrome)

1) `./certs/cert.pem` をダブルクリック  
2) 「証明書のインストール」→「ローカル コンピューター」  
3) 「証明書をすべて次のストアに配置する」→「信頼されたルート証明機関」  
4) 反映後、Chrome を再起動

### Ubuntu (Chrome)

OS の信頼ストアに追加:

```bash
sudo cp ./certs/cert.pem /usr/local/share/ca-certificates/cert.pem
sudo update-ca-certificates
```

もし Chrome で警告が消えない場合は NSS にも追加:

```bash
sudo apt-get install -y libnss3-tools
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "comfyui-local" -i ./certs/cert.pem
```

### iPad (Safari)

1) `cert.pem` を iPad に送る (AirDrop など)  
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

## データ配置の例（モデル置き場）

ComfyUI の想定構成に合わせて `./data/models` 配下へ配置してください。例:

- `./data/models/checkpoints/your_model.safetensors`
- `./data/models/vae/your_vae.safetensors`
- `./data/models/loras/your_lora.safetensors`
- `./data/models/clip/your_clip.safetensors`
- `./data/models/controlnet/your_controlnet.safetensors`
- `./data/models/upscale_models/your_upscaler.pth`

入力は `./data/input`、出力は `./data/output` に保存されます。

## 注意点

- HTTPS を使う場合は起動前に `./certs` に証明書を用意してください。
- Dockerfile は ComfyUI のリリースタグ `v0.8.2` に固定しています。
- 動作検証は Ubuntu Desktop 24.02 + RTX-5070 のみで行っています。
- WSL2 での動作検証は行っていません。

## 上流ライセンス（ComfyUI）

このリポジトリは上流の ComfyUI プロジェクトを Docker で動かすためのものです。
ComfyUI は GPL-3.0 でライセンスされています。ComfyUI の利用・改変・再配布は、
上流ライセンスの条件に従ってください。再配布前に必ず内容をご確認ください。

## 免責

このリポジトリは「現状のまま」提供され、いかなる保証も行いません。
本リポジトリまたは上流ソフトウェアの利用によって生じたいかなる損害についても、
管理者は責任を負いません。自己責任でご利用ください。
