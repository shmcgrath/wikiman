WIKIMAN := $(CURDIR)
NAME=		wikiman
VERSION=	2.14.1
RELEASE=	1
UPSTREAM=	https://github.com/filiparag/wikiman
UPSTREAM_API=	https://api.github.com/repos/filiparag/wikiman/releases/latest

MKFILEREL!=	echo ${.MAKE.MAKEFILES} | sed 's/.* //'
MKFILEABS!=	readlink -f ${MKFILEREL} 2>/dev/null
MKFILEABS+= 	$(shell readlink -f ${MAKEFILE_LIST})
WORKDIR!=	dirname ${MKFILEABS} 2>/dev/null

BUILDDIR:=	${WORKDIR}/pkgbuild
SOURCESDIR:=	${WORKDIR}/srcbuild
PLISTFILE:=	${WORKDIR}/pkg-plist
XDG_DATA_HOME  := $(shell [ -n "$$XDG_DATA_HOME" ] && printf %s "$$XDG_DATA_HOME" || printf %s "$(HOME)/.local/share")
XDG_CONFIG_HOME := $(shell [ -n "$$XDG_CONFIG_HOME" ] && printf %s "$$XDG_CONFIG_HOME" || printf %s "$(HOME)/.config")
DOC_INSTALL_DIR:= $(XDG_DATA_HOME)/doc
WIKIMAN_INSTALL_DIR:= $(XDG_DATA_HOME)/wikiman
BIN_INSTALL_DIR := $(HOME)/.local/bin


.PHONY: build-source-docs \
	install-wikiman install-widgets install-manpage install-sources \
	uninstall-wikiman uninstall-manpage

all: core widgets completions config docs

build-source-docs:
	@./build/sources/tldr.sh $(DOC_INSTALL_DIR)
	@./build/sources/arch.sh $(DOC_INSTALL_DIR)

install-sources:
	@mkdir -p $(WIKIMAN_INSTALL_DIR)/sources
	install -m 755 $(WIKIMAN)/sources/arch.sh $(WIKIMAN_INSTALL_DIR)/sources
	install -m 755 $(WIKIMAN)/sources/tldr.sh $(WIKIMAN_INSTALL_DIR)/sources

install-widgets:
	@mkdir -p $(WIKIMAN_INSTALL_DIR)
	@mkdir -p $(WIKIMAN_INSTALL_DIR)/widgets
	install -m 755 $(WIKIMAN)/widgets/widget.bash $(WIKIMAN_INSTALL_DIR)/widgets
	install -m 755 $(WIKIMAN)/widgets/widget.zsh $(WIKIMAN_INSTALL_DIR)/widgets

install-manpage:
	@mkdir -p $(XDG_DATA_HOME)/man/man1
	install -m 644 wikiman.1.man $(XDG_DATA_HOME)/man/man1/wikiman.1

install-wikiman: install-widgets install-manpage install-sources
	@mkdir -p $(BIN_INSTALL_DIR)
	install -m 755 $(WIKIMAN)/wikiman.sh $(BIN_INSTALL_DIR)/wikiman

uninstall-manpage:
	@rm -f $(XDG_DATA_HOME)/man/man1/wikiman.1

uninstall-wikiman: uninstall-manpage
	rm -f $(BIN_INSTALL_DIR)/wikiman
	rm -rf $(WIKIMAN_INSTALL_DIR)

install-test:
	install -m 755 $(WIKIMAN)/sources/man.sh $(WIKIMAN_INSTALL_DIR)/sources

test-inst:
	@mkdir -p /usr/local/bin
	chmod 755 /usr/local/bin
	install -m755 $(WIKIMAN)/wikiman.sh /usr/local/bin/wikiman 

