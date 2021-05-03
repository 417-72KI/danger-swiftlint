import Danger

// fileImport: DangerExtensions/Shell.swift

let danger = Danger()

danger.message("Validation passed! 🎉")

if let swiftVersion = shell("swift", "--version") {
    danger.message(swiftVersion)
}
if let dangerSwiftVersion = shell("danger-swift", "--version") {
    danger.message("danger-swift: \(dangerSwiftVersion)")
}
if let dangerJSVersion = shell("danger-js", "--version") {
    danger.message("danger-js: \(dangerJSVersion)")
}
if let swiftLintVersion = shell("swiftlint", "version") {
    danger.message("SwiftLint: \(swiftLintVersion)")
}