{% from "usersandgroups/map.jinja" import usersandgroups with context %}

{% set groups = salt['pillar.get']('usersandgroups:groups', {}) %}
{% set users = salt['pillar.get']('usersandgroups:users', {}) %}

# iteration over defined groups
{% for group, data in groups.items() %}
  {% set gid = salt['pillar.get']('usersandgroups:groups:' ~ group ~ ':gid') %}
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
  {% set home = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':home', None) %}
  {% if home is none %}
    {% set home = usersandgroups.home_base ~ user %}
  {% endif %}
  {% set home_parent = salt['file.dirname'](home) %}
  {% set shell = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':shell', None) %}
  {% if shell is none %}
    {% set shell = usersandgroups.shell %}
  {% endif %}
  {% set ssh_key = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':ssh_key', None) %}


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

{% if ssh_key is not none %}
{% set key = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':ssh_key:source', None) %}
user_{{ user }}_sshauth:
  ssh_auth.present:
    - user: {{ user }}
    - source: {{ key }}
{% endif %}

{% endfor %}
