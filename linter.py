#!/opt/venv/bin/python
import os
import sys
import yaml
import hashlib
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


def is_cached(filename, cached):
    filename = os.path.realpath(filename)
    cached_file = os.path.join(
        '/.cache/bearstech/lint', filename.lstrip('/')
    )
    if not os.path.isfile(cached_file):
        return False
    with open(filename, 'rb') as fd:
        current_hash = hashlib.sha1(fd.read()).hexdigest()
    with open(cached_file, 'r') as fd:
        old_hash = fd.read()
    if current_hash == old_hash:
        cached.append(cached_file)
        return True
    return False


def cache(files):
    for filename in files:
        filename = os.path.realpath(filename)
        cached_file = os.path.join(
            '/.cache/bearstech/lint', filename.lstrip('/')
        )
        with open(filename, 'rb') as fd:
            current_hash = hashlib.sha1(fd.read()).hexdigest()
        try:
            os.makedirs(os.path.dirname(cached_file))
        except OSError:
            pass
        with open(cached_file, 'w') as fd:
            fd.write(current_hash)


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
    cached = []
    files = [f for f in files if not is_cached(f, cached)]
    return files, cached


def main():
    log = logging.getLogger('linter')
    if not os.path.isfile('linters.yml'):
        log.critical('No linters.yml found!')
        sys.exit(1)
    if not os.path.isdir('/.cache'):
        log.warning('/.cache is not mounted')
    with open('linters.yml') as fd:
        config = yaml.safe_load(fd.read())
    for name, conf in sorted(config.items()):
        log = logging.getLogger(name)
        files, cached = find(**conf)
        if files:
            args = [LINTERS[name]] + conf.get('options', []) + files
            log.info('Processing %s on %s files (%s files cached)',
                     name, len(files), len(cached))
            log.debug('$ %s', ' '.join(args))
            rc = subprocess.call(args)
            if rc != 0:
                sys.exit(rc)
            else:
                log.debug('Caching results')
                cache(files)
        elif cached:
            log.info('Nothing to process for %s (%s files cached)',
                     name, len(cached))


if __name__ == '__main__':
    main()
