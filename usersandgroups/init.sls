{% from "usersandgroups/map.jinja" import usersandgroups with context %}

# absent/present groups and users
{% set groups = salt['pillar.get']('usersandgroups:groups', {}) %}
{% set users = salt['pillar.get']('usersandgroups:users', {}) %}
{% set absent_groups = salt['pillar.get']('usersandgroups:absent_groups', {}) %}
{% set absent_users = salt['pillar.get']('usersandgroups:absent_users', {}) %}

# configuration
{% set ssh_pubkey_dir = salt['pillar.get']('usersandgroups:config:ssh_pubkey_dir', None) %}

## global files management

{% set files_global = salt['pillar.get']('usersandgroups:config:files', None) %}
# global files enabled
{% if files_global is not none %}
  {% set files_enabled_global = True %}
{% else %}
  {% set files_enabled_global = False %}
{% endif %}
# definition of home base directory and default home dir if defined
{% set files_home_global = salt['pillar.get']('usersandgroups:config:files:home:source', None) %}
{% set files_default_home = salt['pillar.get']('usersandgroups:config:files:home:default_source', None) %}

{% set remove_groups_global = salt['pillar.get']('usersandgroups:config:remove_groups', False) %}

# iteration over defined groups
{% for group, data in groups.items() %}
  {% set gid = salt['pillar.get']('usersandgroups:groups:' ~ group ~ ':gid', None) %}
  {% set system = salt['pillar.get']('usersandgroups:groups:' ~ group ~ ':system', False) %}
group_{{ group }}_present:
  group.present:
    - name: {{ group }}
    - gid: {{ gid }}
    - system: {{ system }}
{% endfor %}

# iteration over defined users
{% for user, data in users.items() %}

  # user configuration
  {% set primary_group = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':primary_group', None) %}
    {% set primary_group = primary_group if primary_group is not none else user %}
  {% set password = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':password') %}
  {% set groups = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':groups') %}
  {% set optional_groups = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':optional_groups', None) %}
  {% set system = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':system', False) %}

  # defining its home, depending of configuration
  {% set home = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':home', None) %}
  {% if home is none %}
    {% set home = usersandgroups.home_base ~ user if user != 'root' else '/root' %}
  {% endif %}

  # defining its shell
  {% set shell = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':shell', None) %}
  {% if shell is none %}
    {% set shell = usersandgroups.shell %}
  {% endif %}

  # do we manage its ssh pubkey
  {% set ssh_absent = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':ssh_pubkey:absent', False) %}
  {% if not ssh_absent %}
    {% set ssh_pubkey = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':ssh_pubkey:source', None) %}
    {% if ssh_pubkey is none and ssh_pubkey_dir is not none %}
        {% set ssh_pubkey = ssh_pubkey_dir ~ user ~ '.pub' %}
    {% endif %}
  {% endif %}

  ## per-user files management

  # per-user files enabled
  {% set files_enabled = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':files:enabled', True) %}
  {% if files_enabled %}
    # per-user definition of files
    {% set files = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':files', None) %}
    {% if files is not none %}
      {% set files_enabled = True %}
    {% else %}
      {% set files_enabled = files_enabled_global %}
    {% endif %}

    # per-user home directory, depending of global ones if not per-user
    {% set files_home = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':files:home:source', files_home_global ~ user) %}
  {% endif %}

  # do we remove its already present groups
  {% set remove_groups = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':remove_groups', remove_groups_global) %}

# creation of all user's groups
{% for group in groups %}
group_{{ user }}_{{ group }}_present:
  group.present:
    - name: {{ group }}
{% endfor %}

# user's primary group creation
{% if primary_group not in groups %}
group_{{ user }}_{{ primary_group }}_present:
  group.present:
    - name: {{ primary_group }}
{% endif %}

# user creation
user_{{ user }}_present:
  user.present:
    - name: {{ user }}
    - password: {{ password }}
    - home: {{ home }}
    - gid: {{ primary_group }}
    - shell: {{ shell }}
    - remove_groups: {{ remove_groups }}
    - groups: {{ groups }}
    - optional_groups: {{ optional_groups }}
    - system: {{ system }}

# home directory creation
# and management of its content if needed
{{ user }}_home:
  {% if files_enabled %}
  file.recurse:
  {% else %}
  file.directory:
  {% endif %}
    - name: {{ home }}
    - user: {{ user }}
    - group: {{ primary_group }}
    {% if files_enabled %}
    - source:
      - {{ files_home }}
      - {{ files_default_home }}
    {% endif %}
    - makedirs: true
    - clean: False
    - include_empty: false
    - require:
      - user: user_{{ user }}_present
      - group: group_{{ user }}_{{ primary_group }}_present

# other files management
{% if files_enabled and files is not none %}
  {% for name, data in files.items() %}
    {% if name != 'home' %}
{{ user }}_{{ name }}:
  file.recurse:
    - name: {{ home }}/{{ data['destination'] }}
    - user: {{ user }}
    - group: {{ primary_group }}
    - source: {{ data['source'] }}
    - makedirs: true
    - clean: False
    - include_empty: true
    {% set options = data['options'] %}
    {% if options is defined %}
      {% for key, value in options.items() %}
    - {{ key }}: {{ value }}
      {% endfor %}
    {% endif %}
    - require:
      - user: user_{{ user }}_present
      - group: group_{{ user }}_{{ primary_group }}_present
      - file: {{ user }}_home
    {% endif %}
  {% endfor %}
{% endif %}

# SSH authorized_keys setting
{% if not ssh_absent and ssh_pubkey is not none %}
user_{{ user }}_sshauth:
  ssh_auth.present:
    - user: {{ user }}
    - source: {{ ssh_pubkey }}
{% endif %}

{% endfor %}

# removing absent users
{% for absent_user in absent_users %}
user_{{ absent_user }}_absent:
  user.absent:
    - name: {{ absent_user }}
    - force: True
{% endfor %}

# removing absent groups
{% for absent_group in absent_groups %}
group_{{ absent_group }}_absent:
  group.absent:
    - name: {{ absent_group }}
{% endfor %}

