CIRCA Belgium buildout
======================

Zope 5 / Python 3 buildout for envcoord.health.fgov.be. Shared Naaya
configuration (``base.cfg``, ``zope5-versions.cfg``, migration scripts) comes
from the ``python3`` branch of https://github.com/eaudeweb/naaya, checked out in
``src/naaya``.

Prerequisites
-------------

* Python 3 with the ``venv`` module
* git, and access to github.com/eaudeweb/naaya
* a C compiler (``build-essential`` on Debian), used to build haproxy

Installation
------------

1. Clone ``src/naaya`` and create the venv with ``zc.buildout`` and
   ``setuptools`` from ``requirements.txt``::

    make bootstrap

   Without SSH access to GitHub::

    make bootstrap NAAYA_REPO=https://github.com/eaudeweb/naaya.git

2. Run buildout and add the Naaya ZCML overrides::

    make install

The LDAP dump reads its configuration from ``var/ldapdump/config.yaml``.

Running
-------

::

    bin/zeoserver start
    bin/envcoord-1 start    # also envcoord-2, envcoord-3
    bin/haproxy -D -f haproxy.cfg

haproxy listens on 127.0.0.1:8060 and balances the instances on ports
8061-8063. ``init_envcoord`` is the init script used in production.

Python 2 Data.fs migration
--------------------------

::

    make migrate

Defaults: ``INSTANCE=envcoord-1``,
``DATAFS=var/storage/groupware/filestorage/Data.fs``. Then reindex the catalog
from the ZMI: portal_catalog -> Advanced -> Update Catalog.
