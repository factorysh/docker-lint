#!/opt/venv/bin/python
import sys
import yaml
import logging
import fnmatch
import subprocess

LINTERS = {
    'flake8': 'flake8',
    'yamllint': 'yamllint',
    'hadolint': 'hadolint',
    'shellcheck': 'shellcheck',
}

if '--debug' in sys.argv:
    level = logging.DEBUG
else:
    level = logging.INFO

logging.basicConfig(level=level, stream=sys.stdout)


def find(include=None, exclude=None, **conf):
    if not include:
        return []
    files = []
    for item in include:
        for pattern in item.split(','):
            std = subprocess.check_output(['find', '-name', pattern])
            std = std.decode('utf8')
            files.extend([
                f for f in std.split('\n')
                if f.strip()
            ])
    if exclude:
        for item in exclude:
            for pattern in item.split(','):
                files = [f for f in files if not fnmatch.fnmatch(f, pattern)]
    return files


def main():
    with open('linters.yml') as fd:
        config = yaml.safe_load(fd.read())
    for name, conf in sorted(config.items()):
        log = logging.getLogger(name)
        files = find(**conf)
        if files:
            args = [LINTERS[name]] + conf.get('options', []) + files
            log.info('Processing %s on %s files', name, len(files))
            log.debug('$ %s', ' '.join(args))
            rc = subprocess.call(args)
            if rc != 0:
                sys.exit(rc)


if __name__ == '__main__':
    main()
