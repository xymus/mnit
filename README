# mnit

The project mnit is a framework for cross-platform application development. As of now it allows to write applications using OpenGL ES 1.1 for Linux and Android. It offers an abstraction over display initialization, assets packaging, application flow and general graphics operations.

# Compilation of mnit

The mnit project must be compiled before being used by another project. It also relies on Nit, so the Nit compiler must be in your PATH and the variable NIT_DIR must be set.

To compile, simply use make.

# Environmental

The variable MNIT_DIR must be set to the root folder of the mnit project.

# Project

A project using mnit must implement a sub-class of mnit::App (see tests for samples) and define a module for each platform. Each custom platform specific module may be very light as it only needs to import the main project and the platform specific module from mnit. However, they can be extended to customize the application behaviour on different platforms.

To compile, call mnitc specifying the target platform with the -t argument.

    mnitc -t android src/simple_android.nit

## Assets

All assets of the project must be in the assets/ directory. Within it you can organize it the way you want.

