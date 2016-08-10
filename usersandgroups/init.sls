{% set users = salt['pillar.get']('usersandgroups', {}) %}

{% for name, data in users.items() %}

{% set home = salt['pillar.get']('usersandgroups:' ~ name ~ ':home') %}
{% set gid = salt['pillar.get']('usersandgroups:' ~ name ~ ':gid') %}
{% set password = salt['pillar.get']('usersandgroups:' ~ name ~ ':password') %}
{% set groups = salt['pillar.get']('usersandgroups:' ~ name ~ ':groups') %}

{% for group in groups %}
user_{{ name }}_{{ group }}_groups:
  group.present:
    - name: {{ group }}
{% endfor %}

user_{{ name }}_present:
  user.present:
    - name: {{ name }}
    - home: {{ home }}
    - gid: {{ gid }}
    - password: {{ password }}
{% endfor %}
