import XCTest
import Foundation
@testable import Argumentable

enum Number {
    case simple(Double)
    case percent(Double)
}

extension Number: Equatable {

    static func ==(lhs: Number, rhs: Number) -> Bool {
        switch (lhs, rhs) {
        case (.simple(let lValue), .simple(let rValue)):
            return lValue == rValue
        case (.percent(let lValue), .percent(let rValue)):
            return lValue == rValue
        default:
            return false
        }
    }

}

extension Number: Argable {

    static var help: String {
        return "You can create from simple or advance"
    }

    static func from(_ value: ParameterType) -> Number? {
        let regularFormatter = NumberFormatter()
        regularFormatter.locale = Locale(identifier: "en_US")

        let percentFormatter = NumberFormatter()
        percentFormatter.locale = Locale(identifier: "en_US")
        percentFormatter.negativeSuffix = "%"
        percentFormatter.positiveSuffix = "%"

        switch value {
        case .none:
            fatalError("Must provide one argument.")
        case .single(let nbr):
            if let percent = percentFormatter.number(from: nbr), nbr.hasSuffix("%") {
                return .percent(percent.doubleValue)
            } else if let regular = regularFormatter.number(from: nbr) {
                return .simple(regular.doubleValue)
            }
            return nil
        case .multiple(_):
            fatalError("Must provide ONE argument")
        }
    }

    static var `default`: Number {
        return .simple(100)
    }

    static var longArg: String? {
        return "--example"
    }

    static var shortArg: String? {
        return "-e"
    }

    static var nbrArguments: Int {
        return 1
    }

}


class ArgumentableTests: XCTestCase {

    func testSimple() {
        L.enable(.verbose)

        var arguments = ["-e", "99"]
        var example: Number = arguments.value()!
        XCTAssertEqual(example, Number.simple(99))

        arguments = ["-e", "99%"]
        example = arguments.value()!
        XCTAssertEqual(example, Number.percent(99))

        arguments = ["-e", "-99%"]
        example = arguments.value()!
        XCTAssertEqual(example, Number.percent(-99))

        arguments = ["-e", "0.911"]
        example = arguments.value()!
        XCTAssertEqual(example, Number.simple(0.911))
    }


    static var allTests = [
        ("testSimple", testSimple),
    ]
}
