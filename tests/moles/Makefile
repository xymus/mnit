default: linux android

linux:
	mkdir -p bin
	../../bin/mnitc -t linux -o bin/moles src/moles_linux.nit

android:
	../../bin/mnitc -t android -i src/moles_android.nit

clean:
	rm -r bin obj
