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

You can also manage user files. Files management can be enabled or disabled
globally or per-user.
The source files can be defined globally, each user will take the directory
with its username. Source can also be defined per-user.
A default source can be defined and be used if no per-user source is found.

All configuration is made using pillar data, read pillar.example to see how.


Tests
=====

This formula is tested on Debian Jessie and Stretch with latest version of Saltstack.
Tests are run with `Test-Kitchen<https://kitchen.ci>`_ and `InSpec<http://inspec.io/>`_.
To use them you need kitchen, `kitchen-salt<https://github.com/simonmcc/kitchen-salt>`_
and `kitchen-inspec<https://github.com/chef/kitchen-inspec>`_.
