.DEFAULT_GOAL := test

.PHONY: test
test:
	zig build test --summary all

.PHONY: clean
clean:
	rm -rf .zig-cache zig-out zig-pkg

.PHONY: cleancache
cleancache:
	rm -rf ~/.cache/zig

.PHONY: cleanall
cleanall: cleancache clean
