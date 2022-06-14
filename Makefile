# Makefile
build:
	coffee -o lib/ -c src/*.coffee
	coffee -o lib/commands/ -c src/commands/*.coffee
	coffee -o lib/tests/ -c src/tests/*.coffee

run:
	coffee index.coffee --nodejs --watch src/*

clean:
	rm -rf lib


