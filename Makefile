.SILENT:

DOCKER_USER = 41772ki
IMAGE_NAME = danger-swiftlint
LATEST_SWIFT_VERSION = 6.1
SWIFT_VERSION = $(LATEST_SWIFT_VERSION)

build:
	cat .github/matrix.json \
		| jq -r '.swiftlint_supported_version["$(SWIFT_VERSION)"]' \
		| xargs -I {} docker build \
			--build-arg SWIFT_VERSION=$(SWIFT_VERSION) \
			--build-arg SWIFT_LINT_REVISION={} \
			--no-cache=true \
			-t $(DOCKER_USER)/$(IMAGE_NAME):$(SWIFT_VERSION) \
			.

swift_version:
	docker run --entrypoint swift $(DOCKER_USER)/$(IMAGE_NAME):$(SWIFT_VERSION) --version

mint_version:
	docker run --entrypoint mint $(DOCKER_USER)/$(IMAGE_NAME):$(SWIFT_VERSION) version

danger_version:
	docker run $(DOCKER_USER)/$(IMAGE_NAME):$(SWIFT_VERSION) --version

swiftlint_version:
	docker run --entrypoint swiftlint $(DOCKER_USER)/$(IMAGE_NAME):$(SWIFT_VERSION) version

run:
	docker run -v `pwd`:`pwd` -w `pwd` -it $(DOCKER_USER)/$(IMAGE_NAME):$(SWIFT_VERSION)

run_local:
	docker run -v `pwd`:`pwd` -w `pwd` -it $(DOCKER_USER)/$(IMAGE_NAME):$(SWIFT_VERSION) local

run_pr:
	docker run -v `pwd`:`pwd` -w `pwd` -it $(DOCKER_USER)/$(IMAGE_NAME):$(SWIFT_VERSION) pr $(shell gh pr list --state all --json url --jq '.[].url' | peco)

buildx:
	docker buildx build \
	--push \
	--platform linux/arm64,linux/amd64 \
	--tag $(DOCKER_USER)/$(IMAGE_NAME):latest \
	--tag $(DOCKER_USER)/$(IMAGE_NAME):$(LATEST_SWIFT_VERSION) \
	--tag $(DOCKER_USER)/$(IMAGE_NAME):$(shell echo ${LATEST_SWIFT_VERSION} | sed -E 's/([0-9]*)((\.[0-9]*){0,2})/\1/g') \
	.

arm64-all:
	@scripts/build_and_push_arm64_image.sh -f $(DOCKER_USER) $(IMAGE_NAME)

arm64:
	@scripts/build_and_push_arm64_image.sh -s $(shell cat .github/matrix.json | jq -r '.swift_version[]' | peco) -f $(DOCKER_USER) $(IMAGE_NAME)
