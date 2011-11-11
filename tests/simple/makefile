default: clean linux android

linux:
	mkdir -p bin
	mnitc -t linux -o bin/simple_linux src/simple_linux.nit

android:
	mnitc -t android -i src/simple_android.nit

clean:
	trash bin obj
