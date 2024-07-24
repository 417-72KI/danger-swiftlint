.SILENT:

DOCKER_USER = 41772ki
IMAGE_NAME = danger-swiftlint
LATEST_SWIFT_VERSION = 5.10
SWIFT_VERSION = $(LATEST_SWIFT_VERSION)

build:
	cat .github/matrix.json \
		| jq -r '.swiftlint_supported_version["$(SWIFT_VERSION)"]' \
		| xargs -I {} docker build \
			--build-arg SWIFT_VERSION=$(SWIFT_VERSION) \
			--build-arg SWIFT_LINT_REVISION={} \
			-t $(DOCKER_USER)/$(IMAGE_NAME):$(SWIFT_VERSION) \
			.

swift_version: build
	docker run --entrypoint swift $(IMAGE_NAME):$(SWIFT_VERSION) --version

mint_version: build
	docker run --entrypoint mint $(IMAGE_NAME):$(SWIFT_VERSION) version

danger_version: build
	docker run $(IMAGE_NAME):$(SWIFT_VERSION) --version

swiftlint_version: build
	docker run --entrypoint swiftlint $(IMAGE_NAME):$(SWIFT_VERSION) version

run: build
	docker run -v `pwd`:`pwd` -w `pwd` -it $(IMAGE_NAME):$(SWIFT_VERSION)

run_local: build
	docker run -v `pwd`:`pwd` -w `pwd` -it $(IMAGE_NAME):$(SWIFT_VERSION) local

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
