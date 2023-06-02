# var
MODULE  = $(notdir $(CURDIR))
module  = $(shell echo $(MODULE) | tr A-Z a-z)
OS      = $(shell uname -o|tr / _)
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
CORES  ?= $(shell grep processor /proc/cpuinfo | wc -l)

# dirs
CWD = $(CURDIR)
BIN = $(CWD)/bin
DOC = $(CWD)/doc
LIB = $(CWD)/lib
SRC = $(CWD)/src
TMP = $(CWD)/tmp
GZ  = $(HOME)/gz
FW  = $(CWD)/fw

# tool
CURL   = curl -L -o
CF     = clang-format

all: files

files: doc

# doc
doxy: .doxygen
	rm -rf docs ; doxygen $< 1>/dev/null

.PHONY: doc
doc:

# install
.PHONY:  install update updev
install: $(OS)_install doc gz
	 $(MAKE) update
update:  $(OS)_update
updev:   update $(OS)_updev

DEBIAN_VER  = $(shell lsb_release -rs)
DEBIAN_NAME = $(shell lsb_release -cs)

.PHONY: GNU_Linux_install GNU_Linux_update GNU_Linux_updev
GNU_Linux_install:
GNU_Linux_update:
ifneq (,$(shell which apt))
	sudo apt update
	sudo apt install -yu `cat apt.txt`
endif
# Debian 10
ifeq ($(DEBIAN_NAME),buster)
#	sudo apt install -t buster-backports kicad
endif
GNU_Linux_updev:
	sudo apt install -yu `cat apt.dev`

.PHONY: gz
gz:
#	$(MAKE) md5

.PHONY: md5
md5: md5sum.txt
	md5sum -c $<

# merge
MERGE += Makefile README.md .gitignore .clang-format .doxygen LICENSE $(S)
MERGE += apt.dev apt.txt
MERGE += .vscode bin doc lib inc src tmp

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)
#	$(MAKE) doxy ; git add -f docs

.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) shadow

.PHONY: zip
ZIP = tmp/$(MODULE)_$(NOW)_$(REL)_$(BRANCH).zip
zip:
	git archive --format zip --output $(ZIP) HEAD
	zip -ru $(ZIP) tmp/*.?pp static/
	unzip -t $(ZIP)
