# Use imutable image tags rather than mutable tags (like ubuntu:18.04)
#FROM ubuntu:focal
FROM --platform=linux/arm64 ubuntu:18.04

# LABEL about the custom image
LABEL maintainer="robin@mordasiewicz.com"
LABEL version="0.1"
LABEL description="ARM64 ansible build"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y \
    && apt install -y \
    libssl-dev python3-dev sshpass apt-transport-https jq moreutils \
    ca-certificates curl gnupg2 software-properties-common python3-pip rsync git \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

#RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
#    && add-apt-repository \
#    "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable" \
#    && apt update -y && apt-get install --no-install-recommends -y docker-ce:amd64 docker-ce-cli:amd64 containerd.io:amd64\
#    && rm -rf /var/lib/apt/lists/*

# Some tools like yamllint need this
# Pip needs this as well at the moment to install ansible
# (and potentially other packages)
# See: https://github.com/pypa/pip/issues/10219
ENV LANG=C.UTF-8

WORKDIR /kubespray
COPY . .

RUN pip3 install --no-cache-dir pip -U \
    && pip3 install --no-cache-dir -r tests/requirements.txt \
    && pip3 install --no-cache-dir -r requirements.txt \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1

RUN KUBE_VERSION=$(sed -n 's/^kube_version: //p' roles/kubespray-defaults/defaults/main.yaml) \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/arm64/kubectl \
    && chmod a+x kubectl \
    && mv kubectl /usr/local/bin/kubectl
