build:
	coffee -o lib/ -c src/*

run: build
	node index.js
