//
//  Components.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Components Object".
    ///
    /// See [OpenAPI Components Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#components-object).
    /// 
    /// This is a place to put reusable components to
    /// be referenced from other parts of the spec.
    public struct Components: Equatable, CodableVendorExtendable {

        public var schemas: ComponentDictionary<JSONSchema>
        public var responses: ComponentDictionary<Response>
        public var parameters: ComponentDictionary<Parameter>
        public var examples: ComponentDictionary<Example>
        public var requestBodies: ComponentDictionary<Request>
        public var headers: ComponentDictionary<Header>
        public var securitySchemes: ComponentDictionary<SecurityScheme>
        public var links: ComponentDictionary<Link>
        public var callbacks: ComponentDictionary<Callbacks>
        internal var pathItems: ComponentDictionary<PathItem>

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            schemas: ComponentDictionary<JSONSchema> = [:],
            responses: ComponentDictionary<Response> = [:],
            parameters: ComponentDictionary<Parameter> = [:],
            examples: ComponentDictionary<Example> = [:],
            requestBodies: ComponentDictionary<Request> = [:],
            headers: ComponentDictionary<Header> = [:],
            securitySchemes: ComponentDictionary<SecurityScheme> = [:],
            links: ComponentDictionary<Link> = [:],
            callbacks: ComponentDictionary<Callbacks> = [:],
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schemas = schemas
            self.responses = responses
            self.parameters = parameters
            self.examples = examples
            self.requestBodies = requestBodies
            self.headers = headers
            self.securitySchemes = securitySchemes
            self.links = links
            self.callbacks = callbacks
            self.vendorExtensions = vendorExtensions
            // Until OpenAPI 3.1, path items cannot actually be stored in the Components Object. This is here to facilitate path item
            // references, albeit in a less than ideal way.
            self.pathItems = [:]
        }

        /// An empty OpenAPI Components Object.
        public static let noComponents: Components = .init()

        public var isEmpty: Bool {
            return self == .noComponents
        }
    }
}

extension OpenAPI.Components {
    public struct ComponentCollision: Swift.Error {
        public let componentType: String
        public let existingComponent: String
        public let newComponent: String
    }

    public mutating func merge(_ other: OpenAPI.Components) throws {
        try schemas.merge(other.schemas, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "schema", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try responses.merge(other.responses, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "responses", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try parameters.merge(other.parameters, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "parameters", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try examples.merge(other.examples, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "examples", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try requestBodies.merge(other.requestBodies, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "requestBodies", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try headers.merge(other.headers, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "headers", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try securitySchemes.merge(other.securitySchemes, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "securitySchemes", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try links.merge(other.links, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "links", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try callbacks.merge(other.callbacks, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "callbacks", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try pathItems.merge(other.pathItems, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "pathItems", existingComponent: String(describing: a), newComponent: String(describing: b)) })
        try vendorExtensions.merge(other.vendorExtensions, uniquingKeysWith: { a, b in throw ComponentCollision(componentType: "vendorExtensions", existingComponent: String(describing: a), newComponent: String(describing: b)) })
    }
}

extension OpenAPI.Components {
    /// The extension name used to store a Components Object name (the key something is stored under
    /// within the Components Object). This is used by OpenAPIKit to store the previous Component name 
    /// of an OpenAPI Object that has been dereferenced (pulled out of the Components and stored inline
    /// in the OpenAPI Document).
    public static let componentNameExtension: String = "x-component-name"
}

extension OpenAPI {

    public typealias ComponentDictionary<T> = OrderedDictionary<ComponentKey, T>
}

// MARK: - Codable
extension OpenAPI.Components: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if !schemas.isEmpty {
            try container.encode(schemas, forKey: .schemas)
        }

        if !responses.isEmpty {
            try container.encode(responses, forKey: .responses)
        }

        if !parameters.isEmpty {
            try container.encode(parameters, forKey: .parameters)
        }

        if !examples.isEmpty {
            try container.encode(examples, forKey: .examples)
        }

        if !requestBodies.isEmpty {
            try container.encode(requestBodies, forKey: .requestBodies)
        }

        if !headers.isEmpty {
            try container.encode(headers, forKey: .headers)
        }

        if !securitySchemes.isEmpty {
            try container.encode(securitySchemes, forKey: .securitySchemes)
        }

        if !links.isEmpty {
            try container.encode(links, forKey: .links)
        }

        if !callbacks.isEmpty {
            try container.encode(callbacks, forKey: .callbacks)
        }

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.Components: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            schemas = try container.decodeIfPresent(OpenAPI.ComponentDictionary<JSONSchema>.self, forKey: .schemas)
                ?? [:]

            responses = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Response>.self, forKey: .responses)
                ?? [:]

            parameters = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Parameter>.self, forKey: .parameters)
            ?? [:]

            examples = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Example>.self, forKey: .examples)
                ?? [:]

            requestBodies = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Request>.self, forKey: .requestBodies)
                ?? [:]

            headers = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Header>.self, forKey: .headers)
                ?? [:]

            securitySchemes = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.SecurityScheme>.self, forKey: .securitySchemes) ?? [:]

            links = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Link>.self, forKey: .links) ?? [:]

            callbacks = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Callbacks>.self, forKey: .callbacks) ?? [:]

            // Until OpenAPI 3.1, path items cannot actually be stored in the Components Object. This is here to facilitate path item
            // references, albeit in a less than ideal way.
            pathItems = [:]

            vendorExtensions = try Self.extensions(from: decoder)
        } catch let error as DecodingError {
            if let underlyingError = error.underlyingError as? KeyDecodingError {
                throw InconsistencyError(
                    subjectName: error.subjectName,
                    details: underlyingError.localizedDescription,
                    codingPath: error.codingPath
                )
            }
            throw error
        }
    }
}

extension OpenAPI.Components {
    internal enum CodingKeys: ExtendableCodingKey {
        case schemas
        case responses
        case parameters
        case examples
        case requestBodies
        case headers
        case securitySchemes
        case links
        case callbacks

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .schemas,
                .responses,
                .parameters,
                .examples,
                .requestBodies,
                .headers,
                .securitySchemes,
                .links,
                .callbacks
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "schemas":
                self = .schemas
            case "responses":
                self = .responses
            case "parameters":
                self = .parameters
            case "examples":
                self = .examples
            case "requestBodies":
                self = .requestBodies
            case "headers":
                self = .headers
            case "securitySchemes":
                self = .securitySchemes
            case "links":
                self = .links
            case "callbacks":
                self = .callbacks
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .schemas:
                return "schemas"
            case .responses:
                return "responses"
            case .parameters:
                return "parameters"
            case .examples:
                return "examples"
            case .requestBodies:
                return "requestBodies"
            case .headers:
                return "headers"
            case .securitySchemes:
                return "securitySchemes"
            case .links:
                return "links"
            case .callbacks:
                return "callbacks"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Components {
    internal mutating func externallyDereference<Context: ExternalLoaderContext>(in context: Context.Type) async throws {
        let oldSchemas = schemas
        let oldResponses = responses
        let oldParameters = parameters
        let oldExamples = examples
        let oldRequestBodies = requestBodies
        let oldHeaders = headers
        let oldSecuritySchemes = securitySchemes

        let oldCallbacks = callbacks

        async let (newSchemas, c1) = oldSchemas.externallyDereferenced(with: context)
        async let (newResponses, c2) = oldResponses.externallyDereferenced(with: context)
        async let (newParameters, c3) = oldParameters.externallyDereferenced(with: context)
        async let (newExamples, c4) = oldExamples.externallyDereferenced(with: context)
        async let (newRequestBodies, c5) = oldRequestBodies.externallyDereferenced(with: context)
        async let (newHeaders, c6) = oldHeaders.externallyDereferenced(with: context)
        async let (newSecuritySchemes, c7) = oldSecuritySchemes.externallyDereferenced(with: context)

//        async let (newCallbacks, c8) = oldCallbacks.externallyDereferenced(with: context)
        var c8 = OpenAPI.Components()
        var newCallbacks = oldCallbacks
        for (key, callback) in oldCallbacks {
            let (newCallback, components) = try await callback.externallyDereferenced(with: context)
            newCallbacks[key] = newCallback
            try c8.merge(components)
        }

        schemas = try await newSchemas
        responses = try await newResponses
        parameters = try await newParameters
        examples = try await newExamples
        requestBodies = try await newRequestBodies
        headers = try await newHeaders
        securitySchemes = try await newSecuritySchemes

        callbacks = newCallbacks

        try await merge(c1)
        try await merge(c2)
        try await merge(c3)
        try await merge(c4)
        try await merge(c5)
        try await merge(c6)
        try await merge(c7)

        try merge(c8)
    }
}

extension OpenAPI.Components: Validatable {}
