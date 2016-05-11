#!/usr/bin/make -f
#
#


# NPM packages needed
NPM_PACKAGES = 							\
	csslint								\
	less								\
	less-plugin-clean-css				\

# Theme
LESS 		 = style_anax-flat.less
LESS_OPTIONS = --strict-imports --include-path=modules/
FONT_AWESOME = modules/font-awesome/fonts/

# Colors
NO_COLOR=\033[0m
TARGET_COLOR=\033[32;01m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m
ACTION=$(TARGET_COLOR)--> 



# target: help - Displays help.
.PHONY:  help
help:
	@echo "Displaying help for this Makefile."
	@echo "Usage:"
	@echo " make [target] ..."
	@echo "target:"
	@egrep "^# target:" Makefile | sed 's/# target: / /g'



# target: npm-config  - Configure where the npm global packages goes.
# target: npm-install - Install npm global packages.
# target: npm-update  - Update npm global packages.
.PHONY: npm-config npm-installl npm-update
npm-config:
	npm config set prefix '~/.npm-packages'

npm-install: 
	npm -g install $(NPM_PACKAGES)

npm-update: 
	npm -g update



# target: prepare-build - Clear and recreate the build directory.
.PHONY: prepare-build
prepare-build:
	@echo "$(ACTION)Preparing the build directory$(NO_COLOR)"
	rm -rf build
	install -d build/css build/lint



# target: less - Compile the stylesheet and update the site with it.
.PHONY: less
less: prepare-build
	@echo "$(ACTION)Compiling LESS stylesheet$(NO_COLOR)"
	lessc $(LESS_OPTIONS) $(LESS) build/css/style.css
	lessc --clean-css $(LESS_OPTIONS) $(LESS) build/css/style.min.css
	cp build/css/style.min.css htdocs/css/style.min.css



# target: less-lint - Lint the less stylesheet.
.PHONY: less-lint
less-lint: less
	@echo "$(ACTION)Linting LESS/CSS stylesheet$(NO_COLOR)"
	lessc --lint $(LESS_OPTIONS) $(LESS) > build/lint/style.less
	- csslint build/css/style.css > build/lint/style.css
	ls -l build/lint/



# target: test - Execute all tests.
.PHONY: test
test: less-lint



# target: update - Update codebase including submodules.
.PHONY: update
update:
	git pull
	git pull --recurse-submodules && git submodule foreach git pull origin master
