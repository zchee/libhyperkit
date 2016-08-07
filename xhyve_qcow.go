// +build qcow

package xhyve

//go:generate ocamlfind ocamlopt -thread -package "cstruct cstruct.lwt io-page io-page.unix uri mirage-block mirage-block-unix qcow unix threads lwt lwt.unix" -c mirage_block_ocaml.ml -o mirage_block_ocaml.cmx
//go:generate ocamlfind ocamlopt -thread -linkpkg -package "cstruct cstruct.lwt io-page io-page.unix uri mirage-block mirage-block-unix qcow unix threads lwt lwt.unix" -output-obj -o mirage_block_ocaml.o mirage_block_ocaml.cmx
//go:generate mv mirage_block_ocaml.o mirage_block_ocaml.syso

/*
#cgo CFLAGS: -DHAVE_OCAML=1 -DHAVE_OCAML_QCOW=1 -DHAVE_OCAML=1 -DVERSION=a82f6c -DVERSION_SHA1=a82f6cba6891ab0e74f3cdae69071c32b6d6ba5a -I/usr/local/lib/ocaml
#cgo LDFLAGS: -L/usr/local/lib/ocaml
*/
import "C"
