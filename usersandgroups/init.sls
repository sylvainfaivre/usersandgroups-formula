{% set users = salt['pillar.get']('usersandgroups', {}) %}

{% for user, data in users.items() %}

{% set home = salt['pillar.get']('usersandgroups:' ~ user ~ ':home') %}
{% set gid = salt['pillar.get']('usersandgroups:' ~ user ~ ':gid') %}
{% set password = salt['pillar.get']('usersandgroups:' ~ user ~ ':password') %}
{% set groups = salt['pillar.get']('usersandgroups:' ~ user ~ ':groups') %}

{% for group in groups %}
user_{{ user }}_{{ group }}_groups:
  group.present:
    - name: {{ group }}
{% endfor %}

user_{{ user }}_present:
  user.present:
    - name: {{ user }}
    - home: {{ home }}
    - gid: {{ gid }}
    - password: {{ password }}
{% endfor %}
