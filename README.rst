CIRCA Belgium buildout
======================

Zope 6 / Python 3 buildout for envcoord.health.fgov.be. Shared Naaya
configuration (``base.cfg``, ``zope6-versions.cfg``, migration scripts) comes
from the ``python3`` branch of https://github.com/eaudeweb/naaya, checked out in
``src/naaya``.

Prerequisites
-------------

* Python 3.9 or newer with the ``venv`` module (``setuptools`` 81 needs 3.9)
* git, and access to github.com/eaudeweb/naaya
* a C/C++ compiler with C++11 support (``build-essential`` on Debian), used
  to build haproxy and the eggs without a matching wheel

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

CentOS 7
--------

CentOS 7 ships Python 3.6, gcc 4.8.5 and glibc 2.17, so Python is built from
source and the eggs without a ``manylinux2014`` wheel (e.g. greenlet) are
compiled with gcc 11 from ``devtoolset-11``.

1. Point the repositories at the CentOS archive (``mirrorlist.centos.org`` is
   gone since the end of life)::

    sudo sed -i -e 's|^mirrorlist=|#mirrorlist=|' -e 's|^#\s*baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' /etc/yum.repos.d/CentOS-*.repo

2. Install the build dependencies and gcc 11 (run the ``sed`` from step 1
   again after ``centos-release-scl``, for the SCLo repositories)::

    sudo yum install -y gcc make openssl11-devel bzip2-devel libffi-devel zlib-devel xz-devel readline-devel sqlite-devel gdbm-devel ncurses-devel libuuid-devel openldap-devel cyrus-sasl-devel wget centos-release-scl
    sudo yum install -y devtoolset-11-gcc devtoolset-11-gcc-c++

3. Build Python 3.12 into ``/opt/python3.12`` against ``openssl11``::

    wget https://www.python.org/ftp/python/3.12.11/Python-3.12.11.tgz
    tar xzf Python-3.12.11.tgz && cd Python-3.12.11
    sed -i 's/PKG_CONFIG openssl /PKG_CONFIG openssl11 /g' configure
    ./configure --prefix=/opt/python3.12 --with-openssl-rpath=auto
    make -j$(nproc) && sudo make altinstall

4. Bootstrap with that Python and run buildout with gcc 11::

    make bootstrap PYTHON=/opt/python3.12/bin/python3.12
    scl enable devtoolset-11 -- make install

Running
-------

::

    bin/zeoserver start
    bin/envcoord-1 start    # also envcoord-2, envcoord-3
    bin/haproxy -D -f haproxy.cfg

haproxy listens on 127.0.0.1:8060 and balances the instances on ports
8061-8063. In production they are started by the systemd unit
``envcoord.service``, which assumes the buildout is in
``/var/local/groupware``::

    cp envcoord.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable --now envcoord

Python 2 Data.fs migration
--------------------------

::

    make migrate

Defaults: ``INSTANCE=envcoord-1``,
``DATAFS=var/storage/groupware/filestorage/Data.fs``.
The last step rebuilds every catalog and packs the database. To rebuild the
catalogs again later (with ``zeoserver`` running for ZEO client instances)::

    bin/envcoord-1 run src/naaya/buildout/Naaya/migration/migrate_zodb.py --reindex-only
