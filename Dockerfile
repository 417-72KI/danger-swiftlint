ARG SWIFT_VERSION=latest
FROM 41772ki/swift-mint:${SWIFT_VERSION}

LABEL repository "https://github.com/417-72KI/danger-swiftlint"
LABEL homepage "https://github.com/417-72KI/danger-swiftlint"
LABEL maintainer "417-72KI <417.72ki@gmail.com>"

ARG DANGER_SWIFT_REVISION=master
ARG SWIFT_LINT_REVISION=master
ARG DANGER_JS_REVISION=master

ENV DANGER_SWIFT_REVISION=${DANGER_SWIFT_REVISION} \
    SWIFT_LINT_REVISION=${SWIFT_LINT_REVISION} \
    DANGER_JS_REVISION=${DANGER_JS_REVISION}

# Install NPM
RUN apt-get update \
    && apt-get install -y npm curl \
    && npm install -g n \
    && n stable \
    && apt-get purge -y npm

# Install Danger-JS(Danger-Swift depends)
RUN npm install -g danger \
    && danger-js --version > /.danger-js_revision

# Install SwiftLint
RUN mint install realm/SwiftLint@${SWIFT_LINT_REVISION} \
    && swiftlint --version > /.swiftlint_revision

# Install Danger-Swift
# Error occurs on running(https://github.com/danger/swift/issues/309)
# RUN mint install danger/swift@${DANGER_SWIFT_REVISION}
RUN git clone --depth=1 -b ${DANGER_SWIFT_REVISION} https://github.com/danger/danger-swift.git ~/danger-swift \
    && git -C ~/danger-swift rev-parse HEAD > /.danger-swift_revision \
    && make -C ~/danger-swift install \
    && rm -rf ~/danger-swift

ADD entrypoint.sh /usr/local/bin/entrypoint
ADD versions.sh /usr/local/bin/show-versions

ENTRYPOINT [ "entrypoint" ]
CMD [ "ci" ]
