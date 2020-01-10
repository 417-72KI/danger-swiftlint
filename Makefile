IMAGE_NAME = danger-swiftlint-dev

build:
	docker build -t $(IMAGE_NAME) .

swift_version: build
	docker run ${IMAGE_NAME} swift --version

mint_version: build
	docker run ${IMAGE_NAME} mint version

danger_version: build
	docker run ${IMAGE_NAME} danger-swift --version

swiftlint_version: build
	docker run ${IMAGE_NAME} swiftlint version

run_local: build
	docker run -v `pwd`:`pwd` -w `pwd` -it $(IMAGE_NAME) local

