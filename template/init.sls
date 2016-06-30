# -*- coding: utf-8 -*-
# vim: ft=sls

include:
  - git

{% for user in salt['pillar.get']('dotfiles', {}).keys() %}

dotfiles-{{ user }}:
  {% if salt['pillar.get']('dotfiles:' + user + 'ssh:host', False) and salt['pillar.get']('dotfiles:' + user + 'ssh:fingerprint', False) %}
  ssh_known_hosts.present:
    - name: {{ salt['pillar.get']('dotfiles:' + user + ':ssh:host') }}
    - user: {{ user }}
    - fingerprint: {{ salt['pillar.get']('dotfiles:' + user + ':ssh:fingerprint') }}
    - enc: {{ salt['pillar.get']('dotfiles:' + user + ':ssh:enc', 'ssh-rsa') }}
  {% endif %}
  git.latest:
    - name: {{ salt['pillar.get']('dotfiles:' + user + ':git:repo') }}
    - rev: {{ salt['pillar.get']('dotfiles:' + user + ':git:branch', 'master') }}
    - user: {{ user }}
    - target: {{ dotfiles_path }}
    - require:
      - pkg: git
      - ssh_known_hosts: dotfiles-{{ user }}
      - file: {{ salt['pillar.get']('dotfiles:' + user + ':path') }}
  cmd.run:
    - name: {{ salt['pillar.get']('dotfiles:' + user + ':cmd') }}
    - user: {{ user }}
    - group: {{ user }}
    - cwd: {{ salt['pillar.get']('dotfiles:' + user + ':path') }}
    - require:
      - git: dotfiles-{{ user }}

{{ salt['pillar.get']('dotfiles:' + user + ':path') }}:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
