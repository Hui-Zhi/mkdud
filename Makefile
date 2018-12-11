GIT2LOG	:= $(shell if [ -x ./git2log ] ; then echo ./git2log --update ; else echo true ; fi)
GITDEPS	:= $(shell [ -d .git ] && echo .git/HEAD .git/refs/heads .git/refs/tags)
VERSION	:= $(shell $(GIT2LOG) --version VERSION ; cat VERSION)
BRANCH	:= $(shell [ -d .git ] && git branch | perl -ne 'print $$_ if s/^\*\s*//')
PREFIX	:= mkdud-$(VERSION)
BINDIR   = /usr/bin

all:    archive

archive: changelog
	@if [ ! -d .git ] ; then echo no git repo ; false ; fi
	mkdir -p package
	git archive --prefix=$(PREFIX)/ $(BRANCH) > package/$(PREFIX).tar
	tar -r -f package/$(PREFIX).tar --mode=0664 --owner=root --group=root --mtime="`git show -s --format=%ci`" --transform='s:^:$(PREFIX)/:' VERSION changelog
	xz -f package/$(PREFIX).tar

changelog: $(GITDEPS)
	$(GIT2LOG) --changelog changelog

install:
	@cp mkdud mkdud.tmp
	@perl -pi -e 's/0\.0/$(VERSION)/ if /VERSION = /' mkdud.tmp
	install -m 755 -D mkdud.tmp $(DESTDIR)$(BINDIR)/mkdud
	@rm -f mkdud.tmp

clean:
	@rm -rf *~ package changelog VERSION

