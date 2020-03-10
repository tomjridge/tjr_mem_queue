# Tjr_mem_queue, a simple inter-thread messaging library



## Introduction

This is a simple messaging library, eg to be used for Lwt messaging between threads. 




## Quick links

* Online **ocamldoc** documentation can be found [here](https://tomjridge.github.io/tjr_mem_queue/index.html). You should probably look at the `With_lwt` module.



## Build, run tests and install

To build, `make` should suffice. 

Then type `make run_tests` to run the tests. The result should look something like this:

~~~
make -k run_tests 
dune build src-test/test_lwt_raw.exe # src-test/test_unix.exe
dune exec src-test/test_lwt_raw.exe
Running 3 writers and 1 reader for 2.0 seconds

Stats: 
  dur=2.0 total_written=9_966_000 total_read=9_966_000 len(q)=0
dune exec src-test/test_lwt_obj.exe
Running 3 writers and 1 reader for 2.0 seconds

Stats: 
  dur=2.0 total_written=9_528_000 total_read=9_528_000 len(q)=0
~~~

Note that this gives a performance of about 5M msgs/s

Finally, `make install` to install.



## Dependencies

| Dependency    | Comment                     |
| ------------- | --------------------------- |
| lwt, lwt.unix | For lwt instance            |
| tjr_monad     | For generic monad interface |



