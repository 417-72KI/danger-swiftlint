IMAGE_NAME = danger-swiftlint-dev

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

