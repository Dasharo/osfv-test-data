# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

FROM registry.fedoraproject.org/fedora-minimal:45

RUN dnf install -y --setopt=install_weak_deps=False \
        curl \
        git-annex \
        gzip \
        tar \
        make \
        mingw64-gcc \
        openssl \
        sbsigntools \
        osslsigncode \
        libfaketime \
        parted \
        dosfstools \
        sudo \
        util-linux \
        lftp \
        openssh-clients \
        jq \
    && dnf clean all

ARG TASK_VERSION=3.45.4
RUN curl -fsSL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz" \
      | tar -xz -C /usr/local/bin task

RUN git config --system --add safe.directory '*'

ENV OSFV_TEST_DATA_IMAGE=1

WORKDIR /workspace
