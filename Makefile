## =========
## erlang.mk
## =========

PROJECT		= switchboard
PROFILE		= dev

SITE_DIR	= site
SITE_DOCS_DIR	= $(SITE_DIR)/doc

ERLC_OPTS = -I include +'{parse_transform, lager_transform}' \
            +debug_info +warn_export_all +warn_shadow_vars +warn_obsolete_guard

EDOC_OPTS = {dir, "$(SITE_DOCS_DIR)"}, no_packages, {subpackages, false}, {preprocess, true}

ifeq ($(PROFILE), dev)
	RELX_OPTS = --dev-mode
endif

DEPS		= lager gproc cowboy jsx social recon
dep_lager	= https://github.com/basho/lager.git 2.0.3
dep_gproc	= https://github.com/uwiger/gproc 0.3
dep_cowboy	= https://github.com/extend/cowboy 0.10.0
dep_jsx		= https://github.com/talentdeficit/jsx v1.4.5
dep_social	= https://github.com/jtmoulia/social cowboy-1.0
dep_recon	= https://github.com/ferd/recon 2.2.0

include erlang.mk


## ====================
## Switchboard specific
## ====================

.PHONY += markdown-docs site-docs


## ==========
## Site Guide
## ==========

update-docs: DOCS_BRANCH = gh-pages
update-docs: docs
	git subtree push --prefix $(SITE_DIR) origin $(DOCS_BRANCH)


## ==============================
## Release tarballing + uploading
## ==============================

S3CMD_CONF	= .s3cmd
S3CMD		= s3cmd -c $(S3CMD_CONF)

$(PROJECT).tar.gz: _rel
	tar -s/_rel// -cvf $@ $<

$(S3CMD_CONF):
	$(S3CMD) --configure

push: switchboard.tar.gz $(S3CMD_CONF)
	$(S3CMD) push
