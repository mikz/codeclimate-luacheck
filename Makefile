IMAGE_NAME ?= codeclimate/codeclimate-luacheck

build:
	docker build . -t $(IMAGE_NAME)
test:
	codeclimate analyze -e luacheck:stable --dev

bash: USER = 9000
bash:
	docker run -it --user $(USER) --rm --volume $(PWD):/code:ro $(IMAGE_NAME) sh

local: export LUA_PATH = lib/?.lua
local: export CONFIG_FILE = config.json
local:
	@bin/engine-lua-files

codeclimate: export CODECLIMATE_DEBUG = 1
codeclimate:
	codeclimate analyze --dev

INTEGRATIONS := $(wildcard integration/*/.)

prepare:
	@git submodule update --init --recursive

integration: prepare $(INTEGRATIONS)

$(INTEGRATIONS):
	@touch $@codeclimate.yml
	$(SHELL) -c "cd $@ && time codeclimate analyze -e luacheck:stable --dev"
	@echo

.PHONY: test local codeclimate bash prepare integration $(INTEGRATIONS)
