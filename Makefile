.DEFAULT_GOAL := test

test:
	zig build test --summary all

clean:
	rm -rf .zig-cache zig-out

.PHONY: test clean
