all: build run

build:
	clang -framework Cocoa -o snow snow.m

run:
	./snow
