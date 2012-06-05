default: server client-linux test

bin-dir:
	mkdir -p bin

test: bin-dir
	../../nit/bin/nitc -o bin/test src/test.nit

client-linux: bin-dir
	../../bin/mnitc -t linux -I lib -o bin/client src/linux_client.nit

server: bin-dir
	../../nit/bin/nitc src/server.nit -o bin/server -I lib

art:
	mkdir -p assets
	#../../bin/svg-to-pngs art/cases.svg assets/
	tools/export.sh art/cases.svg assets/

.PHONY: art
