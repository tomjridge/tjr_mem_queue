(lang dune 2.0)
(name tjr_mem_queue)

;; for opam
(authors              "Tom Ridge <tom.j.ridge@googlemail.com>")
(maintainers          "Tom Ridge <tom.j.ridge@googlemail.com>")
(source               (github tomjridge/tjr_btree))
(homepage             https://github.com/tomjridge/tjr_mem_queue)
(documentation        https://tomjridge.github.io/ocamldocs)
(generate_opam_files  true)


(package 
 (name tjr_mem_queue)
 (synopsis "Simple in-memory message queue")
 (depends lwt tjr_monad))
