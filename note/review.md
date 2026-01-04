# Codexレビュー指摘の扱いメモ

以下の指摘は現状では対応せず、意図的に無視する。

- `deploy.resources` は Swarm 向けで通常の `docker compose` では GPU 指定が無視される点
- ComfyUI/ComfyUI-Manager の clone が最新追従でビルド再現性が無い点
- `omgwtfssl` は一度だけ実行するため、証明書が無い場合は HTTP 起動になる点（TLS 必須ではない運用）

