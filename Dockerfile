# Ubuntuの最新版をベースにする
FROM ubuntu:latest

# 1. OSの情報を「Nubuntu」に書き換える
RUN echo "Nubuntu 1.0 (Based on Ubuntu)" > /etc/issue && \
    echo "Welcome to Nubuntu - Developed by a Grade 5 Engineer" > /etc/motd

# 2. 必要なツールと日本語環境のインストール
# DEBIAN_FRONTEND=noninteractive は、インストール中の質問を自動で飛ばすための設定です
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    firefox \
    curl \
    git \
    wget \
    gpg \
    language-pack-ja \
    fonts-noto-cjk \
    dbus-x11 \
    libasound2 \
    && apt-get clean

# 3. VS Codeのインストール（Microsoftの公式リポジトリを使用）
RUN wget -qO- https://packages.microsoft.com | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com stable main" > /etc/apt/sources.list.d/vscode.list && \
    rm -f packages.microsoft.gpg && \
    apt-get update && apt-get install -y code

# 4. 言語を日本語に設定
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

# 動作確認用に、起動時にbash（ターミナル）を開くように設定
CMD ["/bin/bash"]
