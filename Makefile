# Image URL to use all building/pushing image targets

TAG=$(shell curl  "https://api.github.com/repos/grzegorzgniadek/argocd-appset-substitute-plugin/tags" | jq -r '.[0].name')

BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
HELM_VERSION=$(shell bash semver.sh -b $(BRANCH) -helm -q )

IMG ?= ghcr.io/grzegorzgniadek/argocd-appset-substitute-plugin:$(TAG)
# ENVTEST_K8S_VERSION refers to the version of kubebuilder assets to be downloaded by envtest binary.
ENVTEST_K8S_VERSION = 1.30.0

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

.PHONY: test
test: ## Run go test against code.
	go test ./... -v

.PHONY: helm-replace
helm-replace: ## Replace Version Tag in helm charts values
	TAG=$(TAG) yq -i '.appVersion = strenv(TAG)' charts/argocd-appset-substitute-plugin/Chart.yaml
	TAG=$(TAG) yq -i '.image.tag = strenv(TAG)' charts/argocd-appset-substitute-plugin/values.yaml
	HELM_VERSION=$(HELM_VERSION) yq -i '.version = strenv(HELM_VERSION)' charts/argocd-appset-substitute-plugin/Chart.yaml

##@ Build

.PHONY: build
build: fmt vet ## Build plugin binary.
	go build -o bin/plugin ./cmd/main.go

.PHONY: run
run: fmt vet ## Run a plugin from your host.
	go run ./cmd/main.go

HELMDOCS ?= $(LOCALBIN)/helm-docs

# Create Helm-docs in charts directory
.PHONY: helm-docs
helm-docs: helm-docs-install ## Use helm-docs to create chart README.md
	$(HELMDOCS) --chart-search-root=charts --template-files=charts/_templates.gotmpl

.PHONY: helm
helm: helm-replace helm-docs-install helm-docs ## Replace TAG with version in helm charts, install helm-docs and use helm-docs to create chart README.md

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

##@ Deploy
.PHONY: helm-template
helm-template: helm-replace helm-docs-install helm-docs ## Run helm-template
	helm template argocd-substitute-plugin charts/argocd-appset-substitute-plugin -n argocd --debug

.PHONY: helm-install
helm-install: helm-replace helm-docs-install helm-docs ## Install Helm chart in argocd namespace
	helm upgrade --install argocd-substitute-plugin charts/argocd-appset-substitute-plugin -n argocd

##@ Dependencies

.PHONY: helm-docs
helm-docs-install: $(HELMDOCS) ## Install helm-docs binary.
$(HELMDOCS): $(LOCALBIN) ## Download helm-docs locally if necessary.
	test -s $(LOCALBIN)/helm-docs || GOBIN=$(LOCALBIN) go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

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
