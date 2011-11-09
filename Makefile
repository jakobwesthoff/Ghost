.PHONY: all
all: deps bin lib

.PHONY: clean
clean: clean-bin clean-lib

.PHONY: deps
deps:
	@npm install

.PHONY: bin
bin:
	@for i in bin/*.coffee; do make $$(dirname "$$i")/$$(basename "$$i" .coffee).js; done

.PHONY: clean-bin
clean-bin:
	rm bin/*.js

.PHONY: lib
lib:
	@for i in lib/*.coffee; do make $$(dirname "$$i")/$$(basename "$$i" .coffee).js; done

.PHONY: clean-lib
clean-lib:
	rm lib/*.js

.SUFFIXES: .js .coffee
.coffee.js:
	coffee -c $<
