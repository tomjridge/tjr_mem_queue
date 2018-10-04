DUNE:=opam exec dune

build:
	$(DUNE) build @install
	$(DUNE) build test/test_lwt.exe
	$(DUNE) build test/test_unix.exe

install:
	$(DUNE) install

uninstall:
	$(DUNE) uninstall

clean:
	$(DUNE) clean
