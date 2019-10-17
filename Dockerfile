FROM hadolint/hadolint AS hadolint

FROM bearstech/python-dev:3

COPY --from=hadolint /bin/hadolint /bin/

RUN set -eux \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
                shellcheck\
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  python3 -m venv /opt/venv \
    &&  /opt/venv/bin/pip install --no-cache-dir yamllint flake8 \
    &&  rm -Rf /.cache



ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/venv/bin
COPY scripts/ /scripts/

ENTRYPOINT ["/scripts/linter.py"]

# generated labels

ARG GIT_VERSION
ARG GIT_DATE
ARG BUILD_DATE

LABEL com.bearstech.image.revision_date=${GIT_DATE}

LABEL org.opencontainers.image.authors=Bearstech

LABEL org.opencontainers.image.revision=${GIT_VERSION}
LABEL org.opencontainers.image.created=${BUILD_DATE}

LABEL org.opencontainers.image.url=https://github.com/factorysh/docker-lint
LABEL org.opencontainers.image.source=https://github.com/factorysh/docker-lint/blob/${GIT_VERSION}/Dockerfile

