SRCS_SH := .git-hooks/pre-push
SRCS_GH := $(wildcard .github/**/*)
SRCS_DOCS := $(wildcard **/*.md)
SRCS_RS := Cargo.toml $(wildcard **/*.rs)

SRCS := .git-hooks/.make-witness $(SRCS_RS) $(SRCS_SH) $(SRCS_GH) $(SRCS_DOCS)

make_witness_files := $(wildcard .make-*)


all: build test lint


clean:
	rm -f $(make_witness_files)


build: .make-build

.make-build: $(SRCS)
	@touch $(@)

.make-build-rs: $(SRCS_RS)
	cargo build
	@touch $(@)

.git-hooks/.make-witness:
	@[ -z "${CI}" ] && git config core.hooksPath .git-hooks || true
	touch $(@)



lint: .make-lint-sh .make-lint-gh .make-lint-typos

.make-lint-typos: $(SRCS)
	typos
	@touch $(@)

.make-lint-sh: $(SRCS_SH)
	checkov
	@touch $(@)

.make-lint-gh: $(SRCS_GH)
	actionlint
	@touch $(@)


test: .make-test-rs

.make-test-rs: $(SRCS_RS)
	cargo test
	@touch $(@)


.PHONY: all clean lint test
