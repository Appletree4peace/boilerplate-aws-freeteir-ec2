FROM alpine:3.17

ARG UID=1000
ARG GID=1000
ARG USERNAME=ec2-user
ARG GROUPNAME=ec2-user

ARG TERRAFORM_VERSION=1.4.5
ARG ANSIBLE_VERSION=2.10.7
ARG GLIBC_VERSION=2.35-r0
ARG AWSCLI_VERSION=2.11.11

ENV AWS_ACCOUNT_ID xxx
ENV AWS_ACCESS_KEY_ID xxx
ENV AWS_SECRET_ACCESS_KEY xxx
ENV AWS_SESSION_TOKEN xxx
ENV ANSIBLE_VAULT_PASSWORD xxx
ENV AWS_DEFAULT_REGION ap-southeast-2

## create new users and add to sudoers
RUN addgroup -g ${GID} -S ${GROUPNAME} || true
RUN adduser -u ${UID} -S ${USERNAME} -g ${GID}
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN addgroup ${USERNAME} root

USER ${USERNAME}
WORKDIR /home/${USERNAME}
RUN mkdir -p .ssh
RUN touch .ssh/config

USER root
WORKDIR /root

## install packages
RUN apk add --no-cache \
    sudo \
    bash \
    curl \
    jq \
    make \
    openssh-client \
    python3 \
    py3-pip \
    py3-setuptools \
    py3-wheel \
    && pip3 install --upgrade pip

## install aws cli2
RUN apk --no-cache add \
        binutils \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk \
    && apk add --no-cache --force-overwrite \
        glibc-${GLIBC_VERSION}.apk \
        glibc-bin-${GLIBC_VERSION}.apk \
        glibc-i18n-${GLIBC_VERSION}.apk \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2 \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/current/dist/aws_completer \
        /usr/local/aws-cli/v2/current/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/current/dist/awscli/examples \
        glibc-*.apk \
    && find /usr/local/aws-cli/v2/current/dist/awscli/botocore/data -name examples-1.json -delete \
    && apk --no-cache del \
        binutils \
    && rm -rf /var/cache/apk/*

## install terraform
RUN curl -sSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm /tmp/terraform.zip

## install ansible version 2.10.7
RUN pip3 install ansible==2.10.7 \
    && pip3 install ansible-vault

## install session manager
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" \
    && apk add rpm2cpio \
    && rpm2cpio session-manager-plugin.rpm | cpio -idmv \
    && mv ./usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/ \
    && rm -rf ./usr \
    && rm session-manager-plugin.rpm

USER ${USERNAME}

## ssh key copy
COPY id_rsa.vultr /home/${USERNAME}/.ssh/id_rsa
COPY id_rsa.vultr.pub /home/${USERNAME}/.ssh/id_rsa.pub
RUN sudo chown ${UID}:${GID} /home/${USERNAME}/.ssh/id_rsa
COPY ansible_vault_password /home/${USERNAME}/.ssh/ansible_vault_password
RUN cd /home/${USERNAME}/.ssh \
    && ansible-vault decrypt id_rsa --vault-password-file ansible_vault_password \
    && chmod 600 id_rsa \
    && rm ansible_vault_password

## others
RUN mkdir -p /opt
WORKDIR /opt
