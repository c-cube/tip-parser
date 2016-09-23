
OPTS=-use-ocamlfind -menhir 'menhir --dump --explain'
FLAGS= -w +a-4-44 -safe-string
TARGETS = tip_parser.cma tip_parser.cmxa tip_parser.cmxs tip_cat.native
TO_INSTALL = $(addprefix _build/src/, $(TARGETS) *.cmi tip_parser.a *.mli) \
	     $(wildcard _build/src/*.cmt{,i})

all:
	ocamlbuild $(OPTS) $(TARGETS)

clean:
	ocamlbuild -clean

install: all
	ocamlfind install tip_parser META $(TO_INSTALL)

uninstall:
	ocamlfind remove tip_parser

doc:
	ocamlbuild $(OPTS) src/tip_parser.docdir/index.html

upload-doc: doc
	git checkout gh-pages && \
	  rm -rf dev/ && \
	  mkdir -p dev && \
	  cp -r tip_parser.docdir/* dev/ && \
	  git add --all dev

watch:
	while find src/ -print0 | xargs -0 inotifywait -e delete_self -e modify ; do \
		echo "============ at `date` ==========" ; \
		sleep 0.2; \
		make ; \
	done

test: all
	@[ -d benchmarks ] || (echo "expect benchmarks/ to exist" && exit 1)
	find benchmarks/ -name  '*.smt2' -print0 | xargs -0 ./tip_cat.native -q
	#find benchmarks-zipper/ -name  '*.smt2' -print0 | xargs -0 ./tip_cat.native -q

test-idempotent: all
	@echo test that '`printer | parser`' works
	@for i in benchmarks/**/*.smt2 ; \
	  do echo "$$i"; \
	  (./tip_cat.native "$$i" | ./tip_cat.native -q) || exit 1; \
	  done

.PHONY: doc upload-doc watch clean test
