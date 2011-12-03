MNIT_DIR=$(PWD)

default: tests

mnit:
	nits -i src/mnit/*.nit

linux: mnit
	nits -I src/ -i src/linux/*.nit

android: mnit
	nits -I src/ -i src/android/*.nit

tests: linux android
	make -C tests/simple
	make -C tests/moles

doc:
	nitdoc --log -d doc/mnit --log-dir doc/log/mnit src/mnit/mnit.nit
	nitdoc --log -I src/ -d doc/linux --log-dir doc/log/linux src/linux/linux.nit
	nitdoc --log -I src/ -d doc/android --log-dir doc/log/android src/android/android.nit

.PHONY: doc tests mnit
