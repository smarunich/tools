FROM ubuntu:focal

ARG tf_version="0.13.5"
ARG ansible_version="2.9.15"

# Core 

RUN ln -fs /usr/share/zoneinfo/America/Toronto /etc/localtime && \
    apt-get update -y && \ 
    apt-get install -y \
    python3-pip \
    python3-dev \
    apache2-utils \
    apt-transport-https \
    dnsutils \
    git \
    httpie \
    inetutils-ping \
    iproute2 \
    netcat \
    nmap \
    slowhttptest \
    sshpass \
    tree \
    unzip \
    jq \
    vim \
    lsb-release \
    curl && \
    pip3 install -U ansible==${ansible_version} \
    ansible-lint \
    pylint \
    awscli \
    flask \
    jinja2 \
    jsondiff \
    kubernetes \
    openstacksdk \
    netaddr \
    pandas \
    paramiko \
    pexpect \
    pycrypto \
    pyOpenssl \
    pyparsing \
    pyvmomi \
    pyyaml \
    requests-toolbelt \
    requests \
    xlsxwriter \
    urllib3 \
    hvac \
    yq  

# VMware

RUN cd /tmp && curl -O https://raw.githubusercontent.com/avinetworks/avitools/master/files/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle
RUN /bin/bash /tmp/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle --eulas-agreed --required --console
RUN rm -f /tmp/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle

RUN curl -L https://github.com/vmware/govmomi/releases/download/v0.23.0/govc_linux_amd64.gz \ | gunzip > /usr/local/bin/govc && \
    chmod +x /usr/local/bin/govc

# Azure

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc |   gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && \
    apt-get install -y azure-cli

# GCP

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt \
    cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl \
    https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  \
    add - && apt-get update -y && apt-get install google-cloud-sdk -y

# Kubernetes

RUN curl https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip -o terraform_${tf_version}_linux_amd64.zip &&  \
    unzip terraform_${tf_version}_linux_amd64.zip -d /usr/local/bin && \
    rm -rf terraform_${tf_version}_linux_amd64.zip

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    touch /etc/apt/sources.list.d/kubernetes.list && \
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubectl

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Misc

RUN curl -LO https://github.com/cli/cli/releases/download/v1.2.1/gh_1.2.1_linux_amd64.deb && \
    dpkg -i gh_1.2.1_linux_amd64.deb

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* $HOME/.cache $HOME/go/src $HOME/src

ENV cmd cmd_to_run
CMD eval $cmd
