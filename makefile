#!make
all: install build_runner activate compile

install:
	dart pub get
build_runner:
	dart run build_runner build
compile:
	dart compile exe -o dist/devmy bin/devmy.dart
activate:
	dart pub global activate -s path . --overwrite
