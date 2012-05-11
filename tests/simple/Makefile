default: clean linux android

linux:
	mkdir -p bin
	../../bin/mnitc -t linux -o bin/simple_linux src/simple_linux.nit

android:
	../../bin/mnitc -t android -i src/simple_android.nit

clean:
	rm -rf bin obj
