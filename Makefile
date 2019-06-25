TMP_DOC_DIR:=/tmp/tjr_mem_queue
scratch:=/tmp/l/github/scratch

default: all

test: FORCE
	dune build test/test_lwt.exe test/test_unix.exe

run_tests: test
	dune exec test/test_lwt.exe
	dune exec test/test_unix.exe

-include Makefile.ocaml

# for auto-completion of Makefile target
clean::

