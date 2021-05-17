{%- from "usersandgroups/map.jinja" import usersandgroups with context %}

# defining absent and present groups and users
{%- set groups = salt['pillar.get']('usersandgroups:groups', {}) %}
{%- set users = salt['pillar.get']('usersandgroups:users', {}) %}
{%- set absent_groups = salt['pillar.get']('usersandgroups:absent_groups', {}) %}
{%- set absent_users = salt['pillar.get']('usersandgroups:absent_users', {}) %}

# global configuration of ssh public keys directory
{%- set ssh_pubkey_dir = salt['pillar.get']('usersandgroups:config:ssh_pubkey_dir', None) %}

# :config:files       global files management
#
# enabled if any value is set
{%- set files_global = salt['pillar.get']('usersandgroups:config:files', None) %}
{%- if files_global is not none %}
  {%- set files_enabled_global = True %}
{%- else %}
  {%- set files_enabled_global = False %}
{%- endif %}

# :config:files:home  global definition of base and default sources for $HOME
#
#   :source           each user will look for its named sub-directory as source
#   :default_source   will be copied as-is, if previous is not set (here or
#                      in user config) or if it doesn't exist
{%- set files_home_global = salt['pillar.get']('usersandgroups:config:files:home:source', None) %}
{%- set files_default_home = salt['pillar.get']('usersandgroups:config:files:home:default_source', None) %}

# global option to remove groups from users if not explicitely declared, default False
{%- set remove_groups_global = salt['pillar.get']('usersandgroups:config:remove_groups', False) %}

# global options for home directories
{%- set home_directory_options = salt['pillar.get']('usersandgroups:config:home_directory_options', None) %}

# global option to delete absent_users' files, default False
{%- set purge_absent_users_files = salt['pillar.get']('usersandgroups:config:purge_absent_users_files', False) %}

# iteration over defined groups
{%- for group, data in groups.items() %}
  {%- set gid = salt['pillar.get']('usersandgroups:groups:' ~ group ~ ':gid', None) %}
  {%- set system = salt['pillar.get']('usersandgroups:groups:' ~ group ~ ':system', False) %}
# creation
group_{{ group }}_present:
  group.present:
    - name: {{ group }}
    - gid: {{ gid }}
    - system: {{ system }}
{%- endfor %}

# iteration over defined users
{%- for user, data in users.items() %}

  ## user specific configuration

  {%- set primary_group = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':primary_group', None) %}
    {%- set primary_group = primary_group if primary_group is not none else user %}
  {%- set password = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':password') %}
  {%- set groups = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':groups') %}
  {%- set optional_groups = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':optional_groups', None) %}
  {%- set system = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':system', False) %}

  # definition of $HOME path
  {%- set home = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':home', None) %}
  {%- if home is none %}
    {%- set home = usersandgroups.home_base ~ user if user != 'root' else '/root' %}
  {%- endif %}

  # definition of $HOME source, depending of global config if not
  {%- set files_home = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':files:home:source', None) %}
  {% if files_home is none and files_home_global %}
    {%- set files_home = files_home_global ~ user %}
  {%- elif files_home is none and files_default_home %}
    {%- set files_home = files_default_home %}
  {%- endif %}

  # defining its shell
  {%- set shell = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':shell', None) %}
  {%- if shell is none %}
    {%- set shell = usersandgroups.shell %}
  {%- endif %}

  # ssh public keys management
  #
  # :users:<user>:ssh_pubkey  per-user configuration of SSH pub keys
  #
  #    :manage  manage or not pubkeys, defaults to True
  #    :sources set sources for pubkeys
  #              if not set, use global ssh_pubkey_dir and look for each user pubkey
  {%- set ssh_manage = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':ssh_pubkey:manage', True) %}
  {%- if ssh_manage %}
    {%- set ssh_pubkey = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':ssh_pubkey:sources', None) %}
    {%- if ssh_pubkey is none and ssh_pubkey_dir is not none %}
        {%- set ssh_pubkey = [ssh_pubkey_dir ~ user ~ '.pub'] %}
    {%- endif %}
  {%- endif %}

  # :users:<user>:files   enable or disable per-user file management
  #                        if not set, use global config
  {%- set files = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':files', None) %}
  {%- if files is not none %}
    {%- set files_enabled = True %}
  {%- else %}
    {%- set files_enabled = files_enabled_global %}
  {%- endif %}

  # do we remove its already present groups, depending of global config if not set
  {%- set remove_groups = salt['pillar.get']('usersandgroups:users:' ~ user ~ ':remove_groups', remove_groups_global) %}

# creation of all user's groups
{%- for group in groups|unique %}
group_{{ user }}_{{ group }}_present:
  group.present:
    - name: {{ group }}
{%- endfor %}

# user's primary group creation
{%- if primary_group not in groups %}
group_{{ user }}_{{ primary_group }}_present:
  group.present:
    - name: {{ primary_group }}
{%- endif %}

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
  {%- if files_home %}
  file.recurse:
  {%- else %}
  file.directory:
  {%- endif %}
    - name: {{ home }}
    - user: {{ user }}
    - group: {{ primary_group }}
    {%- if files_home %}
    - source:
      - {{ files_home }}
      {%- if files_enabled_global %}
      - {{ files_default_home }}
      {%- endif %}
    {%- endif %}
    - makedirs: true
    - clean: False
    - include_empty: false
    {%- if home_directory_options is defined %}
      {%- for key, value in home_directory_options.items() %}
    - {{ key }}: {{ value }}
      {%- endfor %}
    {%- endif %}
    - require:
      - user: user_{{ user }}_present
      - group: group_{{ user }}_{{ primary_group }}_present

# other files management
{%- if files_enabled and files is not none %}
  {%- for name, data in files.items() %}
    {%- if name != 'home' %}
{{ user }}_{{ name }}:
  file.recurse:
    - name: {{ home }}/{{ data['destination'] }}
    - user: {{ user }}
    - group: {{ primary_group }}
    - source: {{ data['source'] }}
    - makedirs: true
    - clean: False
    - include_empty: true
    {%- set options = data['options'] %}
    {%- if options is defined %}
      {%- for key, value in options.items() %}
    - {{ key }}: {{ value }}
      {%- endfor %}
    {%- endif %}
    - require:
      - user: user_{{ user }}_present
      - group: group_{{ user }}_{{ primary_group }}_present
      - file: {{ user }}_home
    {%- endif %}
  {%- endfor %}
{%- endif %}

# SSH authorized_keys setting
{%- if ssh_manage and ssh_pubkey is not none %}
  {%- for source in ssh_pubkey %}
user_{{ user }}_sshauth_{{ loop.index0 }}:
  ssh_auth.present:
    - user: {{ user }}
    - source: {{ source }}
    - require:
      - user: user_{{ user }}_present
      - file: {{ user }}_home
  {%- endfor %}
{%- endif %}

{%- endfor %}

# removing absent users
{%- for absent_user in absent_users %}
user_{{ absent_user }}_absent:
  user.absent:
    - name: {{ absent_user }}
    - force: True
  {%- if purge_absent_users_files %}
    - purge: True
  {%- endif %}
{%- endfor %}

# removing absent groups
{%- for absent_group in absent_groups %}
group_{{ absent_group }}_absent:
  group.absent:
    - name: {{ absent_group }}
{%- endfor %}

