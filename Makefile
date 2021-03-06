MNIT_DIR=$(PWD)

default: tests-linux doc

nit: nit/Makefile
	git submodule update nit
	make -C nit

nit/Makefile:
	git submodule update --init nit

tests-linux: nit
	make -C tests/simple linux
	make -C tests/moles linux
	make -C tests/dino linux

tests-android: nit
	make -C tests/simple android
	make -C tests/moles android
	make -C tests/dino android

doc: nit
	nit/bin/nitdoc -I src src/linux/linux.nit src/android/android.nit

.PHONY: doc nit
