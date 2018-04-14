BIN = ./node_modules/.bin
TESTS = $(shell find test -name "*Test.coffee")
.PHONY: test clean

define docker-exec-or-run
	if docker-compose exec salad echo "" &> /dev/null; then docker-compose exec salad $(1); else docker-compose run --service-ports --rm salad $(1); fi
endef

define docker-exec
	docker-compose exec salad $(1) || echo "Please start the docker container with 'make run-dev' seperately"
endef

shell: ## Grants you shell access to the currently running application container.
	$(call docker-exec-or-run,/bin/bash)

build: clean
	@echo "Creating folders"
	@mkdir -p lib
	@mkdir -p build

	@$(BIN)/grunt compile

test: clean
	docker-compose build --force-rm
	@$(call docker-exec-or-run,npm test)

clean:
	@rm -rf lib
	@rm -rf build

define release
	VERSION=`node -pe "require('./package.json').version"` && \
	NEXT_VERSION=`node -pe "require('semver').inc(\"$$VERSION\", '$(1)')"` && \
	node -e "\
		var j = require('./package.json');\
		j.version = \"$$NEXT_VERSION\";\
		var s = JSON.stringify(j, null, 2);\
		require('fs').writeFileSync('./package.json', s);" && \
	node -e "\
		var j = require('./bower.json');\
		j.version = \"$$NEXT_VERSION\";\
		var s = JSON.stringify(j, null, 2);\
		require('fs').writeFileSync('./bower.json', s);" && \
	git commit -m "release $$NEXT_VERSION" -- package.json bower.json && \
	git tag "$$NEXT_VERSION" -m "release $$NEXT_VERSION"
endef

release-patch: build
	@$(call release,patch)

release-minor: build test
	@$(call release,minor)

release-major: build test
	@$(call release,major)

publish:
	git push origin
	git push --tags origin HEAD:master
	npm publish
	@rm -rf lib
