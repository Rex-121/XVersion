

import Foundation

public struct Version {

    /// 主要版本号
    public let major: Int
    
    /// 次要版本号
    public let minor: Int
    
    /// 补丁
    public let patch: Int
    
    /// 初始值
    public let value: [Any?]
    
    
    
    
    /// 版本
    /// - Parameters:
    ///   - major: 主要版本
    ///   - minor: 次要版本
    ///   - patch: 补丁
    public init(major: Int?, minor: Int?, patch: Int?) {
        
        self.init(major: major, minor: minor, patch: patch, value: [major, minor, patch])
        
    }
    
    
    private init(major: Int?, minor: Int?, patch: Int?, value: [Any?]) {
        
        self.major = major.nil_value
        self.minor = minor.nil_value
        self.patch = patch.nil_value

        self.value = value
        
    }

    /// 版本 “0.0.0”
    public static var empty: Version { "0.0.0" }
}

extension Version: RawRepresentable, Codable {
    
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        self.init(stringLiteral: rawValue)
    }
    
    public var rawValue: String { description }
    
}

//MARK: ExpressibleByStringLiteral
extension Version: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        
        let v = value.components(separatedBy: ".").map { Int($0).nil_value }
        
        self.init(major: v.first, minor: v.second, patch: v.third, value: value.components(separatedBy: "."))
        
    }
    
}

extension Version: CustomStringConvertible {
    
    public var description: String { "\(major).\(minor).\(patch)" }
    
}

extension Version: CustomDebugStringConvertible {
    
    public var debugDescription: String { "\(major).\(minor).\(patch) - made by: \(value)" }
    
}


extension Version: Comparable {
    
    public static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major
            && lhs.minor == rhs.minor
            && lhs.patch == rhs.patch
    }
    
    public static func < (lhs: Version, rhs: Version) -> Bool {
        guard lhs.major == rhs.major else { return lhs.major < rhs.major }
        guard lhs.minor == rhs.minor else { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
    
}

extension Optional where Wrapped == Int {
    
    fileprivate var nil_value: Int {
        switch self {
        case .none: return 0
        case .some(let value): return value
        }
    }
    
}


extension RandomAccessCollection {
    
    fileprivate var second: Element? { self.dropFirst().first }
    
    fileprivate var third: Element? { dropFirst(2).first }
    
}
