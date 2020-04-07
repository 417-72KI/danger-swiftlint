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

# Install SwiftLint
RUN mint install realm/SwiftLint@${SWIFT_LINT_REVISION}

# Install Danger-Swift
# Error occurs on running(https://github.com/danger/swift/issues/309)
# RUN mint install danger/swift@${DANGER_SWIFT_REVISION}
RUN git clone --depth=1 -b ${DANGER_SWIFT_REVISION} https://github.com/danger/danger-swift.git ~/danger-swift \
    && make -C ~/danger-swift install \
    && rm -rf ~/danger-swift

# Install NPM
RUN apt-get update \
    && mv /usr/lib/python2.7/site-packages /usr/lib/python2.7/dist-packages; ln -s dist-packages /usr/lib/python2.7/site-package \
    && apt-get install -y npm wget \
    && npm install -g n \
    && n stable \
    && apt-get purge -y npm nodejs

# Install Danger-JS(Danger-Swift depends)
RUN npm install -g danger

# Temporary
# RUN apt-get install -y curl \
#     && curl -o- -L https://yarnpkg.com/install.sh | bash \
#     && npm install -g shx typescript \
#     && mkdir danger-js \
#     && cd danger-js \
#     && git init \
#     && git remote add origin https://github.com/danger/danger-js.git \
#     && git fetch --depth 1 origin ${DANGER_JS_REVISION} \
#     && git reset --hard FETCH_HEAD \
#     && ~/.yarn/bin/yarn install \
#     && ~/.yarn/bin/yarn build \
#     && npm link

ADD entrypoint.sh /usr/local/bin/entrypoint
ADD versions.sh /usr/local/bin/show-versions

ENTRYPOINT [ "entrypoint" ]
CMD [ "ci" ]
