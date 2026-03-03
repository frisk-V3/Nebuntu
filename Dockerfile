# Ubuntuの最新版をベースにする
FROM ubuntu:latest

# OSの情報を「Nubuntu」に書き換える
RUN echo "Nubuntu 1.0 (Based on Ubuntu)" > /etc/issue && \
    echo "Welcome to Nubuntu - Developed by a Grade 5 Engineer" > /etc/motd

# Firefoxと、日本語環境、便利なツールを入れる
RUN apt-get update && apt-get install -y \
    firefox \
    curl \
    git \
    language-pack-ja \
    fonts-noto-cjk \
    && apt-get clean

# 言語を日本語に設定
ENV LANG ja_JP.UTF-8
