//
//  ParameterSchemaContextStyle.swift
//  
//
//  Created by Mathew Polzin on 12/18/22.
//

extension Shared {
    public enum ParameterSchemaContextStyle: String, CaseIterable, Codable {
        case form
        case simple
        case matrix
        case label
        case spaceDelimited
        case pipeDelimited
        case deepObject
    }
}

extension Shared {
    public struct LenientSchemaContextStyle: Decodable {
        public typealias Style = Shared.ParameterSchemaContextStyle
        public let warning: String?
        public let style: Style

        /// An initializer that decodes schema context styles without caring about
        /// the case of the characters (e.g. "FORM" works for the .form case).
        /// Returns both a value for self and a [String] value describing how the value 
        /// needed to be coerced into an acceptable value.
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            let stringValue = try container.decode(String.self)
            let lowercasedValue = stringValue.lowercased()

            switch lowercasedValue {
                case "form":
                self.style = .form
                self.warning = Self.description(from: stringValue, to: .form)
                case "simple":
                self.style = .simple
                self.warning = Self.description(from: stringValue, to: .simple)
                case "matrix":
                self.style = .matrix
                self.warning = Self.description(from: stringValue, to: .matrix)
                case "label":
                self.style = .label
                self.warning = Self.description(from: stringValue, to: .label)
                case "spacedelimited":
                self.style = .spaceDelimited
                self.warning = Self.description(from: stringValue, to: .spaceDelimited)
                case "pipedelimited":
                self.style = .pipeDelimited
                self.warning = Self.description(from: stringValue, to: .pipeDelimited)
                case "deepobject":
                self.style = .deepObject
                self.warning = Self.description(from: stringValue, to: .deepObject)
                default:
                throw InconsistencyError(
                    subjectName: "Style",
                    details: "\(stringValue) could not be coerced into one of the allowed styles: \(Style.allCases.map { $0.rawValue }.joined(separator: ", "))",
                    codingPath: decoder.codingPath
                )
            }
        }

        private static func description(from: String, to: Style) -> String? {
            if from == to.rawValue {
                return nil
            }
            return "The value '\(from)' needed to be coerced into the style '\(to.rawValue)'"
        }
    }
}
