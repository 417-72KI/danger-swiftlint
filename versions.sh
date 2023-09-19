#!/bin/sh

swift --version | grep 'Swift version'
EXIT_CODE=$?
SWIFTLINT_VERSION=$(swiftlint version)
EXIT_CODE=$((EXIT_CODE|$?))
DANGER_JS_VERSION=$(danger --version)
EXIT_CODE=$((EXIT_CODE|$?))
DANGER_SWIFT_VERSION=$(danger-swift --version)
EXIT_CODE=$((EXIT_CODE|$?))

echo "SwiftLint version ${SWIFTLINT_VERSION}"
echo "danger-js version ${DANGER_JS_VERSION}"
echo "danger-swift version ${DANGER_SWIFT_VERSION}"

exit $EXIT_CODE
