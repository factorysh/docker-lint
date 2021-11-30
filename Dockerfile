ARG python_version

FROM hadolint/hadolint AS hadolint

FROM bearstech/python:${python_version}

COPY --from=hadolint /bin/hadolint /bin/

RUN set -eux \
    &&  export http_proxy=${HTTP_PROXY} \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
                python3-venv \
                shellcheck\
    &&  python3 -m venv /opt/venv \
    &&  /opt/venv/bin/pip install --no-cache-dir yamllint flake8 \
    &&  apt-get purge -y \
        python3-venv \
        python-pip-whl \
        python3-distutils \
        python3-lib2to3 \
    &&  apt-get clean \
    &&  rm -rf /.cache /var/lib/apt/lists/*


ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/venv/bin

COPY linter.py /opt/venv/bin/linter.py

ENTRYPOINT ["/opt/venv/bin/linter.py"]

# generated labels

ARG GIT_VERSION
ARG GIT_DATE
ARG BUILD_DATE

LABEL \
    com.bearstech.image.revision_date=${GIT_DATE} \
    org.opencontainers.image.authors=Bearstech \
    org.opencontainers.image.revision=${GIT_VERSION} \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.url=https://github.com/factorysh/docker-lint \
    org.opencontainers.image.source=https://github.com/factorysh/docker-lint/blob/${GIT_VERSION}/Dockerfile
