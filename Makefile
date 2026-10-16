INSTANCE ?= envcoord-1
DATAFS ?= var/storage/groupware/filestorage/Data.fs
NAAYA_BUILDOUT := src/naaya.buildout.naaya
NAAYA_REPO ?= git@github.com:eaudeweb/naaya.buildout.naaya.git
NAAYA_BRANCH ?= pip

.PHONY: bootstrap

bootstrap:
	test -d $(NAAYA_BUILDOUT) || git clone --branch $(NAAYA_BRANCH) $(NAAYA_REPO) $(NAAYA_BUILDOUT)

# '-include' so 'make bootstrap' works before src/naaya.buildout.naaya exists
-include $(NAAYA_BUILDOUT)/pip/site.mk
-include $(NAAYA_BUILDOUT)/migration/migrate.mk

install: haproxy
