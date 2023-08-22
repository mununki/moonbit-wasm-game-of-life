SHELL = /bin/bash

build:
	moon build

watch:
	moon check --watch

convert:
	wat2wasm target/build/main/main.wat --output=www/src/game_of_life.wasm

run: build convert
	cd www && yarn
	cd www && yarn dev
