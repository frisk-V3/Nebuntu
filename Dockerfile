FROM ubuntu:24.04

# 環境変数
ENV DEBIAN_FRONTEND=noninteractive

# 1. 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    wget gpg apt-transport-https curl git vim \
    && rm -rf /var/lib/apt/lists/*

# 2. VS Code リポジトリの追加とインストール
RUN wget -qO- https://packages.microsoft.com | gpg --dearmor > /usr/share/keyrings/microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com stable main" > /etc/apt/sources.list.d/vscode.list \
    && apt-get update && apt-get install -y code \
    && rm -rf /var/lib/apt/lists/*

# 3. Nebuntuの独自設定 (OS名などの書き換え)
RUN echo 'Nebuntu 1.0 (Custom)' > /etc/issue \
    && echo 'Welcome to Nebuntu - Next Ubuntu' > /etc/motd

# 4. ブラウザなどの追加
RUN apt-get update && apt-get install -y firefox && rm -rf /var/lib/apt/lists/*
