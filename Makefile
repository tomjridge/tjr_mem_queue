default: all

test: FORCE
	dune build src-test/test_lwt_raw.exe # src-test/test_unix.exe

run_tests: test
	dune exec src-test/test_lwt_raw.exe
	dune exec src-test/test_lwt_obj.exe
#	dune exec src-test/test_unix.exe

-include Makefile.ocaml

# for auto-completion of Makefile target
clean::

