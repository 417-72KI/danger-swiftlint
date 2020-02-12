#!/bin/sh

swift --version | grep 'Swift version'
echo "SwiftLint version $(swiftlint version)"
echo "danger-js version $(danger --version)"
echo "danger-swift version $(danger-swift --version)"
