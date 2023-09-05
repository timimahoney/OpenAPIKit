//
//  ParameterSchema.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import OpenAPIKitCore

extension OpenAPI.Parameter {
    /// OpenAPI Spec "Parameter Object" schema and style configuration.
    ///
    /// See [OpenAPI Parameter Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#parameter-object)
    /// and [OpenAPI Style Values](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#style-values).
    public struct SchemaContext: Equatable, HasWarnings {
        public let style: Style
        public let explode: Bool
        public let allowReserved: Bool //defaults to false
        public let schema: Either<OpenAPI.Reference<JSONSchema>, JSONSchema>

        public let example: AnyCodable?
        public let examples: OpenAPI.Example.Map?

        public let warnings: [Warning]

        public init(_ schema: JSONSchema,
                    style: Style,
                    explode: Bool,
                    allowReserved: Bool = false,
                    example: AnyCodable? = nil) {
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
            self.schema = .init(schema)
            self.example = example
            self.examples = nil
            self.warnings = []
        }

        public init(_ schema: JSONSchema,
                    style: Style,
                    allowReserved: Bool = false,
                    example: AnyCodable? = nil) {
            self.style = style
            self.allowReserved = allowReserved
            self.schema = .init(schema)
            self.example = example
            self.examples = nil

            self.explode = style.defaultExplode
            self.warnings = []
        }

        public init(schemaReference: OpenAPI.Reference<JSONSchema>,
                    style: Style,
                    explode: Bool,
                    allowReserved: Bool = false,
                    example: AnyCodable? = nil) {
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
            self.schema = .init(schemaReference)
            self.example = example
            self.examples = nil
            self.warnings = []
        }

        public init(schemaReference: OpenAPI.Reference<JSONSchema>,
                    style: Style,
                    allowReserved: Bool = false,
                    example: AnyCodable? = nil) {
            self.style = style
            self.allowReserved = allowReserved
            self.schema = .init(schemaReference)
            self.example = example
            self.examples = nil

            self.explode = style.defaultExplode
            self.warnings = []
        }

        public init(_ schema: JSONSchema,
                    style: Style,
                    explode: Bool,
                    allowReserved: Bool = false,
                    examples: OpenAPI.Example.Map?) {
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
            self.schema = .init(schema)
            self.examples = examples
            self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))
            self.warnings = []
        }

        public init(_ schema: JSONSchema,
                    style: Style,
                    allowReserved: Bool = false,
                    examples: OpenAPI.Example.Map?) {
            self.style = style
            self.allowReserved = allowReserved
            self.schema = .init(schema)
            self.examples = examples
            self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))

            self.explode = style.defaultExplode
            self.warnings = []
        }

        public init(schemaReference: OpenAPI.Reference<JSONSchema>,
                    style: Style,
                    explode: Bool,
                    allowReserved: Bool = false,
                    examples: OpenAPI.Example.Map?) {
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
            self.schema = .init(schemaReference)
            self.examples = examples
            self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))
            self.warnings = []
        }

        public init(schemaReference: OpenAPI.Reference<JSONSchema>,
                    style: Style,
                    allowReserved: Bool = false,
                    examples: OpenAPI.Example.Map?) {
            self.style = style
            self.allowReserved = allowReserved
            self.schema = .init(schemaReference)
            self.examples = examples
            self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))

            self.explode = style.defaultExplode
            self.warnings = []
        }

        public static func == (lhs: OpenAPI.Parameter.SchemaContext, rhs: OpenAPI.Parameter.SchemaContext) -> Bool {
            lhs.style == rhs.style 
                && lhs.explode == rhs.explode 
                && lhs.allowReserved == rhs.allowReserved
                && lhs.schema == rhs.schema
                && lhs.example == rhs.example 
                && lhs.examples == rhs.examples 
        }
    }
}

extension OpenAPI.Parameter.SchemaContext.Style {
    /// Get the default `Style` for the given location
    /// per the OpenAPI Specification.
    ///
    /// See the `style` fixed field under
    /// [OpenAPI Parameter Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#parameter-object).
    public static func `default`(for location: OpenAPI.Parameter.Context) -> Self {
        switch location {
        case .query:
            return .form
        case .cookie:
            return .form
        case .path:
            return .simple
        case .header:
            return .simple
        }
    }

    internal var defaultExplode: Bool {
        switch self {
        case .form:
            return true
        default:
            return false
        }
    }
}

// MARK: - Codable
extension OpenAPI.Parameter.SchemaContext {
    private enum CodingKeys: String, CodingKey {
        case style
        case explode
        case allowReserved
        case schema

        // the following two are alternatives
        case example
        case examples
    }
}

extension OpenAPI.Parameter.SchemaContext {
    public func encode(to encoder: Encoder, for location: OpenAPI.Parameter.Context) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if style != Style.default(for: location) {
            try container.encode(style, forKey: .style)
        }

        if explode != style.defaultExplode {
            try container.encode(explode, forKey: .explode)
        }

        if allowReserved != false {
            try container.encode(allowReserved, forKey: .allowReserved)
        }

        try container.encode(schema, forKey: .schema)

        if examples != nil {
            try container.encode(examples, forKey: .examples)
        } else if example != nil {
            try container.encode(example, forKey: .example)
        }
    }
}

extension OpenAPI.Parameter.SchemaContext {
    public init(from decoder: Decoder, for location: OpenAPI.Parameter.Context) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        schema = try container.decode(Either<OpenAPI.Reference<JSONSchema>, JSONSchema>.self, forKey: .schema)

        if let stylePackage = try container.decodeIfPresent(Shared.LenientSchemaContextStyle.self, forKey: .style) {
            self.style = stylePackage.style
            if let warning = stylePackage.warning {
                self.warnings = [
                    .underlyingError(
                        InconsistencyError(
                            subjectName: "Style", details: warning, codingPath: decoder.codingPath
                        )
                    )
                ]
            } else {
                self.warnings = []
            }
        } else {
            self.style = Style.default(for: location)
            self.warnings = []
        }

        explode = try container.decodeIfPresent(Bool.self, forKey: .explode) ?? style.defaultExplode

        allowReserved = try container.decodeIfPresent(Bool.self, forKey: .allowReserved) ?? false

        if container.contains(.example) {
            example = try container.decode(AnyCodable.self, forKey: .example)
            examples = nil
        } else {
            let examplesMap = try container.decodeIfPresent(OpenAPI.Example.Map.self, forKey: .examples)
            examples = examplesMap
            example = examplesMap.flatMap(OpenAPI.Content.firstExample(from:))
        }
    }
}

extension OpenAPI.Parameter.SchemaContext.Style: Validatable {}
