SHELL = /bin/bash

build:
	moon build

watch:
	moon check --watch

copy-wasm: build
	cp target/wasm-gc/release/build/lib/lib.wasm www/src/game_of_life.wasm

run: build copy-wasm
	cd www && pnpm i
	cd www && pnpm dev
