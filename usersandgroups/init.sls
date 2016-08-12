{% from "usersandgroups/map.jinja" import usersandgroups with context %}

{% set groups = salt['pillar.get']('usersandgroups:groups', {}) %}
{% set users = salt['pillar.get']('usersandgroups:users', {}) %}
{% set ssh_pubkey_dir = salt['pillar.get']('usersandgroups:config:ssh_pubkey_dir', None) %}

# iteration over defined groups
{% for group, data in groups.items() %}
  {% set gid = salt['pillar.get']('usersandgroups:groups:' ~ group ~ ':gid', None) %}
group_{{ group }}_present:
  group.present:
    - name: {{ group }}
    - gid: {{ gid }}
{% endfor %}

# iteration over defined users
{% for user, data in users.items() %}
  {% set gid = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':gid') %}
  {% set password = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':password') %}
  {% set groups = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':groups') %}
  {% set system = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':system', False) %}

  {% set home = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':home', None) %}
  {% if home is none %}
    {% set home = usersandgroups.home_base ~ user %}
  {% endif %}
  {% set home_parent = salt['file.dirname'](home) %}

  {% set shell = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':shell', None) %}
  {% if shell is none %}
    {% set shell = usersandgroups.shell %}
  {% endif %}

  {% set ssh_pubkey = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':ssh_pubkey:source', None) %}
  {% if ssh_pubkey is none and ssh_pubkey_dir is not none %}
      {% set ssh_pubkey = ssh_pubkey_dir ~ user ~ '.pub' %}
  {% endif %}

# creation of all user's groups
{% for group in groups %}
user_{{ user }}_{{ group }}_groups:
  group.present:
    - name: {{ group }}
{% endfor %}

# creation of home parent directory
home_{{ user }}_parent:
  file.directory:
    - name: {{ home_parent }}
    - makedirs: true

user_{{ user }}_present:
  user.present:
    - name: {{ user }}
    - password: {{ password }}
    - home: {{ home }}
    - gid: {{ gid }}
    - shell: {{ shell }}
    - groups: {{ groups }}
    - system: {{ system }}

# SSH authorized_keys setting
{% if ssh_pubkey is not none %}
user_{{ user }}_sshauth:
  ssh_auth.present:
    - user: {{ user }}
    - source: {{ ssh_pubkey }}
{% endif %}

{% endfor %}

