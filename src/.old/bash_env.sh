set -a # export all vars
# set -x # debug

libname=tjr_mem_queue
Libname=Tjr_mem_queue


meta_description="tjr_mem_queue, an in-mem message queue for OCaml threads"

# required_packages="stdlib" 

# FIXME a bit inefficient if recalculating every time
# mls=`ocamlfind ocamldep -package $required_packages -sort -one-line *.ml`
mls=tjr_mem_queue.ml

natives=""
bytes=""


# common ---------------------------------------------------------------



# set these env vars before including the file
function check_env_vars () {
    # http://stackoverflow.com/questions/31164284/shell-script-exiting-script-if-variable-is-null-or-empty
    : ${libname?Need a value}
    : ${Libname?Need a value}
    : ${mls?Need a value}
    : ${meta_description?Need a value}
#    : ${required_packages?Need a value}
}
check_env_vars

# PKGS="-package $required_packages"
PKGS="-I +threads"


# see https://caml.inria.fr/pub/docs/manual-ocaml/comp.html
# WARN="-w @f@p@u@s@40-8-11-26-40-20"
WARN=""

  ocamlc="$DISABLE_BYTE ocamlfind ocamlc   -g -bin-annot $WARN $PKGS"
ocamlopt="$DISABLE_NTVE ocamlfind ocamlopt -g -bin-annot $WARN $PKGS"
ocamldep="ocamlfind ocamldep $PKGS"


# mls ----------------------------------------

cmos="${mls//.ml/.cmo}"
cmxs="${mls//.ml/.cmx}"


# cma,cmxa -------------------------------------------------------------

function mk_cma() {
  $DISABLE_BYTE ocamlfind ocamlc -g -a -o $libname.cma $cmos
}

function mk_cmxa() {
  $DISABLE_NTVE ocamlfind ocamlopt -g -a -o $libname.cmxa $cmxs
}




# meta ----------------------------------------

function mk_meta() {
cat >META <<EOF
name="$libname"
description="$meta_description"
version="??"
requires="$required_packages"
archive(byte)="$libname.cma"
archive(native)="$libname.cmxa"
EOF

}



# doc ----------------------------------------------------

function mk_doc() {
    ocamlfind ocamldoc $PKGS $WARN -html -intro intro.odoc *.ml
    mv *.html ../docs/ocamldoc
    rm *.css
# odoc -----------------------------------------------------------------
# depends on jbuilder really; the following isn't quite right
#    for f in *.cmt; do odoc compile --package $libname $f; done
#    for f in *.odoc; do odoc html -o /tmp $f; done
}


# clean ----------------------------------------------------------------

function clean() {
	rm -f *.{cmi,cmo,cmx,o,cmt} a.out *.cma *.cmxa *.a *.byte *.native *.odoc *.html *.css
}

# ocamlfind install, remove, reinstall --------------------

function install() {
	  ocamlfind install $libname META $libname.{cma,cmxa,a} *.cmx *.o *.cmt *.cmi
}

function remove() {
    ocamlfind remove $libname
}
