
usersandgroups:
  lookup:
    home_base: '/srv/'
  config:
    ssh_pubkey_dir: salt://files/ssh_keys/
    purge_absent_users_files: True
    files:
      home:
        source: salt://files/home/
        default_source: salt://files/home_default/

  groups:
    users:
      gid: 1001
  users:
    foo:
      password: $6$2xYqAULy$Gw9urwgVnoxaMWnubLu6GXPDOBHnaYx0Se7SjjtkewtwpJLGqraFORliWh2TMNdlwlnbFiOVPiA6JV3Qi.B3I.
      home: /home/foo_home
      shell: /bin/sh
      primary_group: users
      groups:
        - foog
        - barg
        - bazg
      files:
        dir:
          source: salt://files/dir
          destination: dir
    bar:
      password: $6$2xYqAULy$Gw9urwgVnoxaMWnubLu6GXPDOBHnaYx0Se7SjjtkewtwpJLGqraFORliWh2TMNdlwlnbFiOVPiA6JV3Qi.B3I.
      system: True
      files:
        home:
          source: salt://files/bar/
    baz:
      ssh_pubkey:
        - manage: False
    foobar:
      ssh_pubkey:
        - sources:
            - salt://files/ssh_keys/foo.pub
            - salt://files/ssh_keys/bar.pub
  absent_users:
    - foobaz
