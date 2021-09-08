SHELL			= /bin/bash

WORKSPACE_OUTPUT_FILE := output.json

include ../Colors.mk

var-tf:
	@echo

define test-namespace
	@if kubectl get namespace $(1) --kubeconfig=$(2) > /dev/null; \
		then $(ECHO) "$(P) $(PASS) CP4NA Namespace Exists";\
		else $(ECHO) "$(P) $(FAIL) CP4NA Namespace not found"; exit 1; \
	fi
endef

define test-endpoint
	@if [[ -n $(1) ]]; \
		then $(ECHO) "$(P) $(PASS) CP4NA Running"; \
		else $(ECHO) "$(P) $(FAIL) CP4NA is not Running. Endpoint not found"; exit 1; \
	fi
endef

test-tf:
	$(call test-namespace,$$(terraform output cp4na_namespace),$$(terraform output kubeconfig))
	$(call test-endpoint,$$(terraform output cp4na_endpoint))

test-sch:
	@[[ -e $(WORKSPACE_OUTPUT_FILE) ]]
	$(call test-namespace,$$(cat $(WORKSPACE_OUTPUT_FILE) | jq -r '.[].output_values[].cp4na_namespace.value'),$$(cat $(WORKSPACE_OUTPUT_FILE) | jq -r '.[].output_values[].kubeconfig.value'))
	$(call test-endpoint,$$(cat $(WORKSPACE_OUTPUT_FILE) | jq -r '.[].output_values[].cp4na_endpoint.value'))
