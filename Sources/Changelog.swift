import ArgumentParser
import Foundation
import Markdown
import OSLog

extension Logger {
    static let changelog = Logger(subsystem: "swift-changelog-parser", category: "changelog")

}

@main
struct Changelog: ParsableCommand {

    static let  configuration = CommandConfiguration(
        abstract: "Get items from a Changelog.md file for a specific release or that are unreleased.",
        version: "1.0.0"
    )

    enum Release: ExpressibleByArgument, CustomStringConvertible {
        case unreleased
        case latest
        case release(String)

        var description: String {
            switch self {
            case .unreleased:
                return defaultValueDescription
            case .latest:
                return "latest"
            case let .release(value):
                return value
            }
        }

        var defaultValueDescription: String {
            "unreleased"
        }

        init?(argument: String) {
            switch argument.lowercased() {
            case "unreleased":
                self = .unreleased
            case "latest":
                self = .latest
            default:
                self = .release(argument)
            }
        }
        
        func filterForFirstMatching(_ heading: Heading) -> Bool {
            switch self {
            case .latest:
                heading.plainText.lowercased() != Release.unreleased.description
            case .unreleased, .release:
                heading.plainText.lowercased() == description
            }
        }
    }

    @Argument(help: "Path to Changelog.md file")
    var path: String

    @Option(name: .shortAndLong, help: "Get a specific list of changes")
    var release: Release = .unreleased

    func validate() throws {
        guard FileManager.default.fileExists(atPath: path) else {
            throw ValidationError("Changelog does not exist at path \(path)")
        }
    }

    func run() throws {
        let document = try Document(parsing: URL(filePath: path))
        let heading = document.children
            .compactMap { $0 as? Heading }
            .filter { $0.level == 2 }
            .first { release.filterForFirstMatching($0) }

        guard let heading else {
            throw ValidationError("Changelog does not contain '\(release.description.localizedCapitalized)' section")
        }

        let list = document.child(at: heading.indexInParent + 1)
        guard let list, list is UnorderedList else {
            Logger.changelog.info("Changelog does not contain elements in the '\(release.description.localizedCapitalized, privacy: .public)' section")
            print("")
            return
        }

        print(list.format().trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
