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
    # && mv /usr/lib/python2.7/site-packages /usr/lib/python2.7/dist-packages; ln -s dist-packages /usr/lib/python2.7/site-package \
    && apt-get install -y nodejs-dev node-gyp libssl1.0-dev npm wget \
    && npm install -g n \
    && n stable \
    && apt-get purge -y npm nodejs

# Install Danger-JS(Danger-Swift depends)
RUN npm install -g danger

# Install SwiftLint
RUN mint install realm/SwiftLint@${SWIFT_LINT_REVISION}

# Install Danger-Swift
# Error occurs on running(https://github.com/danger/swift/issues/309)
# RUN mint install danger/swift@${DANGER_SWIFT_REVISION}
RUN git clone --depth=1 -b ${DANGER_SWIFT_REVISION} https://github.com/danger/danger-swift.git ~/danger-swift \
    # Unknown error occurs on release build
    # swift: /home/buildnode/jenkins/workspace/oss-swift-5.3-package-linux-ubuntu-18_04/llvm-project/llvm/lib/CodeGen/AsmPrinter/DwarfExpression.cpp:572: void llvm::DwarfExpression::addFragmentOffset(const llvm::DIExpression *): Assertion `FragmentOffset >= OffsetInBits && "overlapping or duplicate fragments"' failed.
    && sed -e 's/release/debug/g' ~/danger-swift/Makefile > ~/danger-swift/Makefile_tmp \
    && mv ~/danger-swift/Makefile_tmp ~/danger-swift/Makefile \
    && make -C ~/danger-swift install \
    && rm -rf ~/danger-swift

ADD entrypoint.sh /usr/local/bin/entrypoint
ADD versions.sh /usr/local/bin/show-versions

ENTRYPOINT [ "entrypoint" ]
CMD [ "ci" ]
