DOCKER_USER = 41772ki
IMAGE_NAME = danger-swiftlint
LATEST_SWIFT_VERSION = 5.7

build:
	docker build -t $(IMAGE_NAME) .

swift_version: build
	docker run --entrypoint swift ${IMAGE_NAME} --version

mint_version: build
	docker run --entrypoint mint ${IMAGE_NAME} version

danger_version: build
	docker run ${IMAGE_NAME} --version

swiftlint_version: build
	docker run --entrypoint swiftlint ${IMAGE_NAME} version

run: build
	docker run -v `pwd`:`pwd` -w `pwd` -it $(IMAGE_NAME)

run_local: build
	docker run -v `pwd`:`pwd` -w `pwd` -it $(IMAGE_NAME) local

buildx:
	docker buildx build \
	--push \
	--platform linux/arm64,linux/amd64 \
	--tag $(DOCKER_USER)/$(IMAGE_NAME):latest \
	--tag $(DOCKER_USER)/$(IMAGE_NAME):$(LATEST_SWIFT_VERSION) \
	--tag $(DOCKER_USER)/$(IMAGE_NAME):$(shell echo ${LATEST_SWIFT_VERSION} | sed -E 's/([0-9]*)((\.[0-9]*){0,2})/\1/g') \
	.

buildx-5.6:
	docker buildx build \
	--push \
	--platform linux/arm64,linux/amd64 \
	--build-arg SWIFT_VERSION=5.6 \
	--build-arg SWIFT_LINT_REVISION=$(shell cat .github/matrix.json | jq -rc '.swiftlint_supported_version."5.6"') \
	--tag $(DOCKER_USER)/$(IMAGE_NAME):5.6 \
	.
