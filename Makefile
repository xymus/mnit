MNIT_DIR=$(PWD)

default: tests-linux

tests-linux:
	make -C tests/simple linux
	make -C tests/moles linux

tests-android:
	make -C tests/simple android
	make -C tests/moles android

doc:
	nitdoc -I src src/linux/linux.nit src/android/android.nit

.PHONY: doc tests mnit
