default: linux

linux:
	mkdir -p bin
	mnitc -t linux -o bin/text src/text_linux.nit

android:
	mnitc -t android -i src/text_android.nit

clean:
	rm -r bin obj
