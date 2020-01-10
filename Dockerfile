FROM 41772ki/swift-mint:latest

LABEL maintainer "417-72KI <417.72ki@gmail.com>"

ENV DANGER_SWIFT_REVISION=master
ENV SWIFT_LINT_REVISION=0.38.2

RUN mint install realm/SwiftLint@${SWIFT_LINT_REVISION} && \
    mint install danger/swift@${DANGER_SWIFT_REVISION}

# Install NPM
RUN mv /usr/lib/python2.7/site-packages /usr/lib/python2.7/dist-packages; ln -s dist-packages /usr/lib/python2.7/site-package

RUN apt-get update \
    && mv /usr/lib/python2.7/site-packages /usr/lib/python2.7/dist-packages; ln -s dist-packages /usr/lib/python2.7/site-package \
    && apt-get install -y npm

RUN npm install -g danger
