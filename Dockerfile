FROM 41772ki/swift-mint:latest

LABEL repository "https://github.com/417-72KI/Docker-Danger-SwiftLint"
LABEL homepage "https://github.com/417-72KI/Docker-Danger-SwiftLint"
LABEL maintainer "417-72KI <417.72ki@gmail.com>"

ARG DANGER_SWIFT_REVISION=master
ARG SWIFT_LINT_REVISION=master

ENV DANGER_SWIFT_REVISION=${DANGER_SWIFT_REVISION} \
    SWIFT_LINT_REVISION=${SWIFT_LINT_REVISION}

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
    && apt-get install -y npm

# Install Danger-JS(Danger-Swift depends)
RUN npm install -g danger

ENTRYPOINT [ "danger-swift" ]
CMD [ "ci" ]
