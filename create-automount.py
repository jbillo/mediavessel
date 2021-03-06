#!/usr/bin/env python3
import argparse
import os
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))


def try_create_directory(where: str):
    try:
        os.mkdir(where)
    except FileExistsError:
        pass


def generate_automount(where: str, unit_name_prefix: str, description: str = ''):
    with open(os.path.join(SCRIPT_DIR, 'templates', 'automount.template')) as f:
        content = f.read()

    # Could replace with Jinja2 or another templating engine, but that would require additional pips
    content = content.replace('{{ description }}', description)
    content = content.replace('{{ where }}', where)

    # write content to filesystem
    with open(f'/etc/systemd/system/{unit_name_prefix}.automount', 'w') as f:
        f.write(content)


def generate_mount(what: str, where: str, unit_name_prefix: str, description: str = '', mount_type: str = 'cifs',
                   options: str = ''):
    with open(os.path.join(SCRIPT_DIR, 'templates', 'mount.template')) as f:
        content = f.read()

    # Could replace with Jinja2 or another templating engine, but that would require additional pips
    content = content.replace('{{ description }}', description)
    content = content.replace('{{ what }}', what)
    content = content.replace('{{ where }}', where)
    content = content.replace('{{ mount_type }}', mount_type)
    content = content.replace('{{ options }}', options)

    # write content to filesystem
    with open(f'/etc/systemd/system/{unit_name_prefix}.mount', 'w') as f:
        f.write(content)


def daemon_reload():
    subprocess.run(["systemctl", "daemon-reload"])


def service_start_and_enable(unit_name_prefix: str):
    subprocess.run(["systemctl", "start", f'{unit_name_prefix}.automount'])
    subprocess.run(["systemctl", "enable", f'{unit_name_prefix}.automount'])


def _main():
    parser = argparse.ArgumentParser()
    parser.add_argument('what', help='The resource to mount, usually the remote CIFS or NFS server and path, '
                                     'eg: //server/data')
    parser.add_argument('where', help='Where to mount the resource (eg: /mnt/nas)')
    parser.add_argument('--type', help='Type of filesystem to mount such as "cifs" or "nfs"', default='cifs')
    parser.add_argument('--description', help='Free-form description of the mount', default='')
    parser.add_argument('--options', help='Options to pass to the mount that you would put in fstab', default='')
    args = parser.parse_args()

    unit_name_prefix = args.where
    if unit_name_prefix.startswith('/'):
        unit_name_prefix = unit_name_prefix[1:]
    if unit_name_prefix.endswith('/'):
        unit_name_prefix = unit_name_prefix[:-1]
    unit_name_prefix = unit_name_prefix.replace('/', '-')

    if not args.description:
        last_dash = args.where.rfind('-')
        args.description = args.description[last_dash:]

    try_create_directory(args.where)
    generate_automount(args.where, unit_name_prefix, args.description)
    generate_mount(args.what, args.where, unit_name_prefix, args.description, args.type, args.options)
    daemon_reload()
    service_start_and_enable(unit_name_prefix)


if __name__ == '__main__':
    _main()
