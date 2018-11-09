DUNE:=opam exec dune

build:
	$(DUNE) build @install
	$(DUNE) build test/test_lwt.exe
	$(DUNE) build test/test_unix.exe

install:
	$(DUNE) install

uninstall:
	$(DUNE) uninstall

doc: FORCE
	$(DUNE) build @doc

view_doc:
	google-chrome  _build/default/_doc/_html/index.html


run_tests:
	$(DUNE) exec test/test_lwt.exe
	$(DUNE) exec test/test_unix.exe

clean:
	$(DUNE) clean



FORCE:
