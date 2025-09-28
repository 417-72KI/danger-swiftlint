import Danger

// fileImport: DangerExtensions/Shell.swift

let danger = Danger()

if let swiftLintVersion = shell("swiftlint", "version") {
    danger.message("SwiftLint: \(swiftLintVersion)")
} else {
    danger.fail("SwiftLint is not installed.")
}
if let dangerJSVersion = shell("danger-js", "--version") {
    danger.message("danger-js: \(dangerJSVersion)")
} else {
    danger.fail("danger-js is not installed.")
}
if let dangerSwiftVersion = shell("danger-swift", "--version") {
    danger.message("danger-swift: \(dangerSwiftVersion)")
} else {
    danger.fail("danger-swift is not installed.")
}
if let swiftVersion = shell("swift", "--version") {
    danger.message(swiftVersion)
} else {
    danger.fail("swift is not installed.")
}

_ = "This line should be detected by custom rule `test` in SwiftLint."

SwiftLint.lint(inline: true)

switch danger.warnings.count {
case 0: danger.fail("SwiftLint may not run correctly.")
case 1 where danger.fails.isEmpty: danger.message("Validation passed! 🎉")
case 1: break
default: danger.warn("Some unexpected warnings were found.")
}
