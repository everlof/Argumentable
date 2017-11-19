import SwiftyBeaver

public struct L {

    /// Enable logging from this library by calling `L.enable`
    internal static let og = SwiftyBeaver.self

    public static func enable(_ minLevel: SwiftyBeaver.Level = .warning) {
        let console = ConsoleDestination()
        console.useTerminalColors = true
        console.minLevel = minLevel
        self.og.addDestination(console)
    }

}

public enum ParameterType {
    case none
    case single(String)
    case multiple([String])
}

protocol Argable {

    static var help: String { get }

    static func from(_ : ParameterType) -> Self?

    static var `default`: Self { get }

    static var longArg: String? { get }

    static var shortArg: String? { get }

    static var nbrArguments: Int { get }

}

extension Array where Element == String {

    mutating func value<T: Argable>() -> T? {
        let args = [T.longArg, T.shortArg].flatMap { $0 }

        guard args.count > 0 else {
            L.og.warning("\(T.self) has not `longArg` or `shortArg`")
            return nil
        }

        L.og.verbose("Will look for arguments: \(args)")

        for arg in args {
            if let index = index(of: arg) {
                L.og.verbose("Has argument: `\(arg)`")

                if T.nbrArguments == 0 {
                    return T.from(.none)
                }

                if T.nbrArguments > 1 {
                    fatalError("`nbrArguments` > 1 is currently unsupported.")
                }

                if index + 1 >= count {
                    L.og.error("Missing value for argument `\(arg)`")
                }

                L.og.verbose("Will ask `\(T.self)` to create value from=\(self[index + 1])")
                return T.from(.single(self[index + 1]))
            }
        }

        return nil
    }

}
