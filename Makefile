# Image URL to use all building/pushing image targets
TAG=$(shell cat VERSION)
REPOSITORY ?= ghcr.io/grzegorzgniadek/argocd-appset-substitute-plugin
IMG ?= $(REPOSITORY):v$(TAG)

# Go Version from go.mod file to use for installing tools. This is used to ensure that the correct version of Go is used when installing tools, regardless of the version of Go installed on the system.
GO_VERSION := $(shell go list -m -f '{{.GoVersion}}')
export GOTOOLCHAIN := go$(GO_VERSION)

# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= docker

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

KUBECTL ?= kubectl
MAKE ?= make

.PHONY: all
all: build

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk command is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: fmt
fmt: ## Run go fmt against code.
	go fmt ./...

.PHONY: vet
vet: ## Run go vet against code.
	go vet ./...

.PHONY: lint
lint: golangci-lint-binary-install ## Run golangci-lint linter
	"$(GOLANGCI_LINT)" run

.PHONY: lint-fix
lint-fix: golangci-lint-binary-install ## Run golangci-lint linter and perform fixes
	"$(GOLANGCI_LINT)" run --fix

.PHONY: lint-config
lint-config: golangci-lint-binary-install ## Verify golangci-lint linter configuration
	"$(GOLANGCI_LINT)" config verify

.PHONY: test
test: ## Run go test against code.
	go test ./... -v

##@ Build

.PHONY: build
build: fmt vet ## Build plugin binary.
	go build -o bin/plugin ./cmd/main.go

.PHONY: run
run: fmt vet ## Run a plugin from your host.
	go run ./cmd/main.go

# If you wish to build the manager image targeting other platforms you can use the --platform flag.
# (i.e. docker build --platform linux/arm64). However, you must enable docker buildKit for it.
# More info: https://docs.docker.com/develop/develop-images/build_enhancements/
.PHONY: docker-build
docker-build: ## Build docker image with the plugin.
	$(CONTAINER_TOOL) build -t ${IMG} .

.PHONY: docker-push
docker-push: ## Push docker image with the plugin.
	$(CONTAINER_TOOL) push ${IMG}

# PLATFORMS defines the target platforms for the manager image be built to provide support to multiple
# architectures. (i.e. make docker-buildx IMG=myregistry/mypoperator:0.0.1). To use this option you need to:
# - be able to use docker buildx. More info: https://docs.docker.com/build/buildx/
# - have enabled BuildKit. More info: https://docs.docker.com/develop/develop-images/build_enhancements/
# - be able to push the image to your registry (i.e. if you do not set a valid value via IMG=<myregistry/image:<tag>> then the export will fail)
# To adequately provide solutions that are compatible with multiple platforms, you should consider using this option.
PLATFORMS ?= linux/arm64,linux/amd64,linux/s390x,linux/ppc64le
.PHONY: docker-buildx
docker-buildx: ## Build and push docker image for the plugin for cross-platform support
	# copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into Dockerfile.cross, and preserve the original Dockerfile
	sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' Dockerfile > Dockerfile.cross
	- $(CONTAINER_TOOL) buildx create --name argocd-appset-substitute-plugin-builder
	$(CONTAINER_TOOL) buildx use argocd-appset-substitute-plugin-builder
	- $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag ${IMG} -f Dockerfile.cross .
	- $(CONTAINER_TOOL) buildx rm argocd-appset-substitute-plugin-builder
	rm Dockerfile.cross

ifndef ignore-not-found
  ignore-not-found = false
endif

##@ Dependencies

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

## Tool Binaries
KUBECTL ?= kubectl
# Use kind from PATH if available, otherwise fall back to bin/kind (installed by kind-install)
KIND ?= $(or $(shell command -v kind 2>/dev/null),$(LOCALBIN)/kind)
HELM ?= $(or $(shell command -v helm 2>/dev/null),$(LOCALBIN)/helm)
GOLANGCI_LINT ?= $(or $(shell command -v golangci-lint 2>/dev/null),$(LOCALBIN)/golangci-lint)
HELMDOCS ?= $(or $(shell command -v helm-docs 2>/dev/null),$(LOCALBIN)/helm-docs)

## Tool Versions
HELM_VERSION ?= v4.3.1
KIND_VERSION ?= v0.33.0
GOLANGCI_LINT_VERSION ?= v2.14.0

.PHONY: helm-docs-binary-install
helm-docs-binary-install: $(HELMDOCS) ## Install helm-docs binary.
$(HELMDOCS): $(LOCALBIN) ## Download helm-docs locally if necessary.
	test -s $(LOCALBIN)/helm-docs || GOBIN=$(LOCALBIN) go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest

.PHONY: golangci-lint-binary-install
golangci-lint-binary-install: $(GOLANGCI_LINT) ## Download golangci-lint locally if necessary.
$(GOLANGCI_LINT): $(LOCALBIN)
	$(call go-install-tool,$(GOLANGCI_LINT),github.com/golangci/golangci-lint/v2/cmd/golangci-lint,$(GOLANGCI_LINT_VERSION))
	@test -f .custom-gcl.yml && { \
		echo "Building custom golangci-lint with plugins..." && \
		$(GOLANGCI_LINT) custom --destination $(LOCALBIN) --name golangci-lint-custom && \
		mv -f $(LOCALBIN)/golangci-lint-custom $(GOLANGCI_LINT); \
	} || true

.PHONY: kind-binary-install
kind-binary-install: $(LOCALBIN) ## Download kind locally if it is not already installed.
	@if [ -x "$(KIND)" ]; then \
		echo "Using kind: $(KIND)"; \
	else \
		echo "Downloading sigs.k8s.io/kind/cmd/kind@$(KIND_VERSION)"; \
		GOBIN=$(LOCALBIN) go install sigs.k8s.io/kind/cmd/kind@$(KIND_VERSION); \
	fi

.PHONY: helm-binary-install
helm-binary-install: $(LOCALBIN) ## Download helm locally if it is not already installed.
	@if [ -x "$(HELM)" ]; then \
		echo "Using helm: $(HELM)"; \
	else \
		echo "Downloading helm"; \
		GOBIN=$(LOCALBIN) go install helm.sh/helm/v4/cmd/helm@$(HELM_VERSION); \
	fi

##@ E2E Tests
.PHONY: kind-create-cluster
kind-create-cluster: kind-binary-install ## Create kind cluster for e2e tests
	if ! $(KIND) get clusters | grep -q 'e2e'; then \
		$(KIND) create cluster --name e2e; \
	else \
		echo "Kind cluster 'e2e' already exists"; \
	fi

.PHONY: kind-load-image
kind-load-image: ## Load plugin image into kind cluster
	$(KIND) load docker-image $(IMG) --name e2e

.PHONY: kind-testing
kind-testing: helm-binary-install docker-build kind-binary-install kind-create-cluster kind-load-image  ## Run e2e tests
	$(HELM) upgrade --install argocd argo-cd --namespace argocd --create-namespace --repo https://argoproj.github.io/argo-helm/ --wait
	$(HELM) upgrade --install argocd-substitute-plugin --namespace argocd charts/argocd-appset-substitute-plugin/ --wait
	$(KUBECTL) apply -f examples
	@$(KUBECTL) get deploy argocd-substitute-plugin-controller -n argocd -o yaml |grep 'image:'
	sleep 10
	$(MAKE) verify-substitution
	$(MAKE) kind-delete-cluster

.PHONY: kind-delete-cluster
kind-delete-cluster: ## Delete kind cluster after e2e tests
	$(KIND) delete cluster --name e2e

.PHONY: verify-substitution
verify-substitution: ## Verify that ConfigMap variables are substituted in the Application
	@cm_values=$$(kubectl get cm cluster-vars -n default -o jsonpath='{.data}' | jq -r '.[]' | tr '\n' ' '); \
	secret_values=$$(kubectl get secret cluster-vars2 -n default -o jsonpath='{.data}' | jq -r '.[]' | while read -r b; do echo "$$b" | base64 --decode; echo; done | tr '\n' ' '); \
	all_values="$$cm_values $$secret_values"; \
	app_values=$$(kubectl get applications.argoproj.io -n argocd pod-info -o yaml | yq -r '.spec.sources[0].helm.valuesObject | .[]' | tr '\n' ' '); \
	for val in $$all_values; do \
		if [[ -z "$$val" ]]; then continue; fi; \
		if [[ $$app_values == *"$$val"* ]]; then \
			echo "✓ Found in application: $$val"; \
		else \
			echo "✗ Missing in application: $$val"; \
			exit 1; \
		fi; \
	done; \
	echo "All ConfigMap and Secret variables are present in the Application."

##@ Helm-docs Generate

.PHONY: helm-docs-generate
helm-docs-generate: helm-docs-binary-install ## Generate Charts README.md
	$(HELMDOCS) --chart-search-root=charts --template-files=charts/_templates.gotmpl

##@ Helm-Deployment
## Namespace to deploy the Helm release
HELM_NAMESPACE ?= argocd
## Name of the Helm release
HELM_RELEASE ?= argocd-substitute-plugin
## Path to the Helm chart directory
HELM_CHART_DIR ?= charts/argocd-appset-substitute-plugin
## Additional arguments to pass to helm commands
HELM_EXTRA_ARGS ?=

.PHONY: argocd-install
argocd-install: helm-binary-install  ## Run helm-template
	@if ! $(KUBECTL) get ns argocd >/dev/null 2>&1; then \
		echo "Installing Argo CD in namespace 'argocd'..."; \
		$(HELM) -n argocd upgrade --install --create-namespace --repo https://argoproj.github.io/argo-helm argocd argo-cd; \
	else \
		echo "Argo CD is already installed in namespace 'argocd'."; \
	fi

.PHONY: helm-template
helm-template: helm-binary-install helm-docs-binary-install helm-docs ## Run helm-template
	${HELM} template argocd-substitute-plugin charts/argocd-appset-substitute-plugin -n argocd --debug

.PHONY: helm-deploy
helm-deploy: helm-binary-install argocd-install ## Install Helm chart in argocd namespace
	${HELM} upgrade --install argocd-substitute-plugin charts/argocd-appset-substitute-plugin -n argocd \
		--set controller.image.repository=$(REPOSITORY) \
		--set controller.image.tag=v$(TAG) \
		--wait

.PHONY: helm-uninstall
helm-uninstall: ## Uninstall the Helm release from the K8s cluster.
	$(HELM) uninstall $(HELM_RELEASE) --namespace $(HELM_NAMESPACE)

.PHONY: helm-status
helm-status: ## Show Helm release status.
	$(HELM) status $(HELM_RELEASE) --namespace $(HELM_NAMESPACE)

.PHONY: helm-history
helm-history: ## Show Helm release history.
	$(HELM) history $(HELM_RELEASE) --namespace $(HELM_NAMESPACE)

.PHONY: helm-rollback
helm-rollback: ## Rollback to previous Helm release.
	$(HELM) rollback $(HELM_RELEASE) --namespace $(HELM_NAMESPACE)

##@ Production

.PHONY: release
release:   ## Release a new version of the controller.
	@echo "Releasing version ${TAG} with image ${IMG}..."
	TAG=v$(TAG) yq -i '.appVersion = strenv(TAG)' charts/argocd-appset-substitute-plugin/Chart.yaml
	TAG=$(TAG) yq -i '.version = strenv(TAG)' charts/argocd-appset-substitute-plugin/Chart.yaml
	TAG=v$(TAG) yq -i '.controller.image.tag = strenv(TAG)' charts/argocd-appset-substitute-plugin/values.yaml
	$(MAKE) helm-docs-generate

# go-install-tool will 'go install' any package with custom target and name of binary, if it doesn't exist
# $1 - target path with name of binary (ideally with version)
# $2 - package url which can be installed
# $3 - specific version of package
define go-install-tool
@[ -f $(1) ] || { \
set -e; \
package=$(2)@$(3) ;\
echo "Downloading $${package}" ;\
GOBIN=$(LOCALBIN) go install $${package} ;\
mv "$$(echo "$(1)" | sed "s/-$(3)$$//")" $(1) ;\
}
endef
