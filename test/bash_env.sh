set -a # export all vars


PKGS="-package tjr_mem_queue_lwt,lwt.unix -linkpkg"

# see https://caml.inria.fr/pub/docs/manual-ocaml/comp.html
# WARN="-w @f@p@u@s@40-8-11-26-40-20"
WARN=""

  ocamlc="$DISABLE_BYTE ocamlfind ocamlc   -g -bin-annot $WARN $PKGS"
ocamlopt="$DISABLE_NTVE ocamlfind ocamlopt -g -bin-annot $WARN $PKGS"
ocamldep="ocamlfind ocamldep $PKGS"



# clean ----------------------------------------------------------------

function clean() {
	rm -f *.{cmi,cmo,cmx,o,cmt} a.out *.cma *.cmxa *.a *.byte *.native *.odoc *.html *.css
}

