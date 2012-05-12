# MNit

The project MNit is a framework for cross-platform application development. As of now it allows to write applications using OpenGL ES 1.1 for Linux and Android. It offers an abstraction over display initialization, assets packaging, application flow and general graphics operations.

# Requirements

Make sure you have all development libraries for the Nit system and your target platform. On Debian like systems, to begin you need you need the packages: git-core build-essential graphiz. For Linux compilation: libgles1-mesa-dev libsdl1.2-dev libsdl-image1.2-dev libsdl-ttf2.0-dev. For Android, you must install the Android SDK and NDK.

# Installation

Clone the repository anywhere, cd in the repository and run make to compile the Nit compiler and run the tests. Afterwards, add the bin folder to your PATH and set MNIT\_DIR to the root folder of the MNit repository.

# Project

A project using MNit must implement a sub-class of mnit::App (see tests for samples) and define a module for each platform. Each custom platform specific module may be very light as it only needs to import the main project and the platform specific module from MNit. However, they can be extended to customize the application behaviour on different platforms.

To compile, call mnitc specifying the target platform with the -t argument.

    mnitc -t linux src/moles_linux.nit
    mnitc -t android src/moles_android.nit

## Quick start

To begin a new project using MNit, you can use the tool mnit-new-project. It will generate the basic folder structure and stub files for you. Example call:

	mnit-new-project your_project_name org.your_java_domain

## Assets

All assets of the project must be in the assets/ directory. Within it you can organize it the way you want.

## Tests and examples

The tests directory contains two examples using MNit. Both can be compiled for Linux and Android.

The test _simple_ is limited to the most basic use of the system. It can be used to test inputs and assets.

The test _moles_ is a simple game which uses the assets to load images. It is a better example for a real game.
