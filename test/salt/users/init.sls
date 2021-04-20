group_foobaz:
  group.present:
    - name: foobaz
    - gid: 1100

user_foobaz:
  user.present:
    - name: foobaz
    - uid: 1100
    - gid: foobaz
