==============
usersandgroups
==============

A simple formula to configure users and groups via pillar.
I found existing ones too complicated or buggy for my needs.

Available states
================

.. contents::
    :local:

``usersandgroups``
------------------

Configures users' home directory, group, shell, the user itself, secondary groups.

It also manages per-user SSH authorized_keys files. Two possibilities:

* indicate a ssh_pubkey.source pillar for a user
* indicate a global config.ssh_pubkeys_dir value

The formula will first look for a per-user value and, if it doesn't exist, 
search for a {{ user }}.pub file in the config.ssh_pubkeys_dir if it exists.
You can also indicate that a user have no ssh pubkey.

All configuration is made using pillar data, read pillar.example to see how.

