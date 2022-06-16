# Makefile
build:
	coffee -o lib/ -c src/*.coffee
	coffee -o lib/commands/ -c src/commands/*.coffee
	coffee -o lib/tests/ -c test/*.coffee

run:
	coffee index.coffee --nodejs

clean:
	rm -rf lib


