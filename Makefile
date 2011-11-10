.PHONY: all
all: deps bin lib

.PHONY: clean
clean: clean-bin clean-lib

.PHONY: deps
deps:
	@npm install

.PHONY: bin
bin:
	@for i in bin/*.coffee; do make --no-print-directory $$(dirname "$$i")/$$(basename "$$i" .coffee).js; done

.PHONY: clean-bin
clean-bin:
	@find bin/ -iname "*.js"|while read i; do rm "$$i"; done

.PHONY: lib
lib:
	@find lib/ -iname "*.coffee"|while read i; do make --no-print-directory $$(dirname "$$i")/$$(basename "$$i" .coffee).js; done

.PHONY: clean-lib
clean-lib:
	@find lib/ -iname "*.js"|while read i; do rm "$$i"; done

.SUFFIXES: .js .coffee
.coffee.js:
	coffee -c $<
