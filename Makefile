MNIT_DIR=$(PWD)

default: tests-linux doc

nit:
	make -C nit

tests-linux: nit
	make -C tests/simple linux
	make -C tests/moles linux

tests-android: nit
	make -C tests/simple android
	make -C tests/moles android

doc: nit
	nit/bin/nitdoc -I src src/linux/linux.nit src/android/android.nit

.PHONY: doc nit
