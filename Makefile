# -----------------------------------------------------------------------------
# includeing xhyve original config.mk
-include xhyve.mk


# -----------------------------------------------------------------------------
# ocaml-qcow bindings

HAVE_OCAML_QCOW := $(shell if ocamlfind query qcow uri >/dev/null 2>/dev/null ; then echo YES ; else echo NO; fi)

ifeq ($(HAVE_OCAML_QCOW),YES)
CGO_CFLAGS += -DHAVE_OCAML=1 -DHAVE_OCAML_QCOW=1 -DHAVE_OCAML=1

OCAML_WHERE := $(shell ocamlc -where)
OCAML_LDLIBS := -L$(OCAML_WHERE) \
	$(shell ocamlfind query cstruct)/cstruct.a \
	$(shell ocamlfind query cstruct)/libcstruct_stubs.a \
	$(shell ocamlfind query io-page)/io_page.a \
	$(shell ocamlfind query io-page)/io_page_unix.a \
	$(shell ocamlfind query io-page)/libio_page_unix_stubs.a \
	$(shell ocamlfind query lwt.unix)/liblwt-unix_stubs.a \
	$(shell ocamlfind query lwt.unix)/lwt-unix.a \
	$(shell ocamlfind query lwt.unix)/lwt.a \
	$(shell ocamlfind query threads)/libthreadsnat.a \
	$(shell ocamlfind query mirage-block-unix)/libmirage_block_unix_stubs.a \
	-lasmrun -lbigarray -lunix

build: CGO_CFLAGS += -I$(OCAML_WHERE)
build: CGO_LDFLAGS += $(OCAML_LDLIBS)
build: GO_BUILD_TAGS += qcow2
build: generate
endif


# -----------------------------------------------------------------------------
# make rules

build:
	CGO_CFLAGS="$(CGO_CFLAGS)" CGO_LDFLAGS="$(CGO_LDFLAGS)" go build -v -x -tags=$(GO_BUILD_TAGS) .

mirage_block_ocaml.o:
	go generate -v -x -tags=$(GO_BUILD_TAGS)

generate: mirage_block_ocaml.o


vendor-fetch:
	-git clone https://github.com/docker/hyperkit.git hyperkit
	# cherry-picked from https://github.com/mist64/xhyve/pull/81
	# Fix non-deterministic delays when accessing a vcpu in "running" or "sleeping" state.
	-cd hyperkit; curl -Ls https://patch-diff.githubusercontent.com/raw/mist64/xhyve/pull/81.patch | patch -N -p1
	# experimental support for raw devices - https://github.com/mist64/xhyve/pull/80
	-cd hyperkit; curl -Ls https://patch-diff.githubusercontent.com/raw/mist64/xhyve/pull/80.patch | patch -N -p1

patch-generate: patch-apply
	-cd hyperkit; git diff > ../xhyve.patch

patch-apply:
	-cd hyperkit; patch -Nl -p1 -F4 < ../xhyve.patch

sync: clean clone-xhyve apply-patch
	find . \( -name \*.orig -o -name \*.rej \) -delete
	for file in $(SRC); do \
		cp -f $$file $$(basename $$file) ; \
		rm -rf $$file ; \
	done
	cp -r hyperkit/include include
	cp hyperkit/README.md README.hyperkit.md
	cp hyperkit/README.xhyve.md .


clean:
	${RM} *.a *.o *.syso *.cmi *.cmx

.PHONY: build clone-xhyve sync patch-apply patch-generate clean
