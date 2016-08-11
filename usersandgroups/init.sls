{% from "usersandgroups/map.jinja" import usersandgroups with context %}

{% set users = salt['pillar.get']('usersandgroups', {}) %}

# iteration over all defined users
{% for user, data in users.items() %}
  {% set gid = salt['pillar.get']('usersandgroups:' ~ user ~ ':gid') %}
  {% set password = salt['pillar.get']('usersandgroups:' ~ user ~ ':password') %}
  {% set groups = salt['pillar.get']('usersandgroups:' ~ user ~ ':groups') %}
  {% set home = salt['pillar.get']('usersandgroups:' ~ user ~ ':home', None) %}
  {% if home is none %}
    {% set home = usersandgroups.home_base ~ user %}
  {% endif %}
  {% set home_parent = salt['file.dirname'](home) %}

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
    - home: {{ home }}
    - gid: {{ gid }}
    - password: {{ password }}
{% endfor %}
