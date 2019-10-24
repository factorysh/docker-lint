Linter docker images by bearstech
==================================

- [bearstech/lint](https://hub.docker.com/r/bearstech/lint/)

Dockerfiles
-----------

Dockerfiles are available at https://github.com/factorysh/docker-lint

Usage
-----

Add a `linters.yml` to your project:

```
$ cat linters.yml
---

flake8:
    include:
        - "*.py"
    # exclude test files
    exclude:
        - "*tests/*"

shellcheck:
    include:
        - "*.sh"

yamllint:
    include:
        - "*.yaml"
        - "*.yml"

hadolint:
    include:
        - "Dockerfile*"
    # extra options to pass to hadolint binary
    options:
        - "--ignore=DL3006"
        - "--ignore=DL3008"
```

Then run:

```
$ docker run \
    --rm -u $(id -u) -w /$(basename $PWD) \
    -v $PWD:/$(basename $PWD) \
    -v $HOME/.cache:/.cache \
    bearstech/lint
```

Licence
-------

GPLv3, © 2019

