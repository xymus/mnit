linux:
	mkdir -p bin
	mnitc -t linux -o bin/dino src/dino_linux.nit

android:
	mnitc -t android -i src/dino_android.nit

pngs:
	mkdir -p assets/images
	svg-to-pngs art/drawing.svg assets/images
