.PHONY: all
all: bin

.PHONY: clean
clean: clean-bin

.PHONY: bin
bin:
	for i in bin/*.coffee; do make $$(dirname "$$i")/$$(basename "$$i" .coffee).js; done

.PHONY: clean-bin
clean-bin:
	rm bin/*.js

.SUFFIXES: .js .coffee
.coffee.js:
	coffee -c $<
