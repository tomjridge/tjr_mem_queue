all:
	$(MAKE) build
	$(MAKE) install
	$(MAKE) clean

build:
	$(MAKE) -C src
	$(MAKE) -C lwt

install:
	$(MAKE) -C src install
	$(MAKE) -C lwt install

uninstall:
	$(MAKE) -C src uninstall
	$(MAKE) -C lwt uninstall

clean:
	$(MAKE) -C src clean
	$(MAKE) -C lwt clean
	$(MAKE) -C test clean
