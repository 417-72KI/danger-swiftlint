FROM 41772ki/swift-mint:latest

LABEL maintainer "417-72KI <417.72ki@gmail.com>"

ENV DANGER_SWIFT_REVISION=master
ENV SWIFT_LINT_REVISION=0.38.2

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
