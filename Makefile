BIN = ./node_modules/.bin
TESTS = $(shell find test -name "*Test.coffee")

build:
	# $(BIN)/coffee --compile --output lib/ src/

test: build
	@NODE_ENV=testing ./node_modules/.bin/mocha \
	  -r should -r coffee-script \
	  --reporter spec --timeout 2000 \
	  ./test/server.coffee $(TESTS)

clean:
	@rm -rf lib/*

define release
	VERSION=`node -pe "require('./package.json').version"` && \
	NEXT_VERSION=`node -pe "require('semver').inc(\"$$VERSION\", '$(1)')"` && \
	node -e "\
		var j = require('./package.json');\
		j.version = \"$$NEXT_VERSION\";\
		var s = JSON.stringify(j, null, 2);\
		require('fs').writeFileSync('./package.json', s);" && \
	git commit -m "release $$NEXT_VERSION" -- package.json && \
	git tag "$$NEXT_VERSION" -m "release $$NEXT_VERSION"
endef

release-patch: build test
	@$(call release,patch)

release-minor: build test
	@$(call release,minor)

release-major: build test
	@$(call release,major)

publish:
	git push --tags origin HEAD:master
	npm publish
