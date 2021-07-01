PLUGIN_NAME := sweagle
REMOTE      := https://github.com/sweagleExpert/integrations/helm/plugins/$(PLUGIN_NAME)

.PHONY: install
install:
	helm plugin install $(REMOTE)

.PHONY: link
link:
	helm plugin install .