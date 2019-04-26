.. _readme:

usersandgroups-formula
======================

|img_travis| |img_sr|

.. |img_travis| image:: https://travis-ci.com/daks/usersandgroups-formula.svg?branch=master
   :alt: Travis CI Build Status
   :scale: 100%
   :target: https://travis-ci.com/daks/usersandgroups-formula
.. |img_sr| image:: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release

A SaltStack formula to manage system users and groups.

.. contents:: **Table of Contents**

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

Available states
----------------

.. contents::
    :local:

``usersandgroups``
^^^^^^^^^^^^^^^^^^

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


Testing
-------

Linux testing is done with ``kitchen-salt``.

``kitchen converge``
^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``usersandgroups`` main state, ready for testing.

``kitchen verify``
^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``kitchen destroy``
^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``kitchen test``
^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``kitchen login``
^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.

