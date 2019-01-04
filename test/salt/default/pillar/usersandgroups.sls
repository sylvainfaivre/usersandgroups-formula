
usersandgroups:
  lookup:
    home_base: '/srv/'
  config:
    ssh_pubkey_dir: salt://ssh_keys/
  groups:
    users:
      gid: 1001
  users:
    foo:
      password: $6$2xYqAULy$Gw9urwgVnoxaMWnubLu6GXPDOBHnaYx0Se7SjjtkewtwpJLGqraFORliWh2TMNdlwlnbFiOVPiA6JV3Qi.B3I.
      home: /home/foo_home
      shell: /bin/sh
      primary_group: users
    bar:
      password: $6$2xYqAULy$Gw9urwgVnoxaMWnubLu6GXPDOBHnaYx0Se7SjjtkewtwpJLGqraFORliWh2TMNdlwlnbFiOVPiA6JV3Qi.B3I.
      system: True
    baz:
      ssh_pubkey:
        - manage: False
