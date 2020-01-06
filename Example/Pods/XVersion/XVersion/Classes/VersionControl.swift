//
//  File.swift
//  
//
//  Created by Tyrant on 2019/12/17.
//

import Foundation


open class VersionControl: Decodable {
    
    /// 后台决定是否需要强更
    public let isForce: Bool
    
    /// 当前版本
    public var current: Version {
        guard let value = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return .empty }
        return Version(stringLiteral: value)
    }
    
    /// 后台最新版本号
    public let latest: Version
    
    /// 最低要求的版本号
    public let minimum: Version?
    
    /// 更新信息
    public let updateInfo: String?
    
    /// 更新地址
    public let ipaUrlString: String?
    
    /// build号
    public var build: String? { Bundle.main.infoDictionary?["CFBundleVersion"] as? String }
    
    
    /// 是否需要更新
    public func needUpdate() -> Update? {
                
        /// 目前已是最新版本
        if isTheLatestVersion { return nil }
        
        var overrideForce = isForce
        
        if let minimum = minimum {
            overrideForce = overrideForce || (minimum > current)
        }
                
        return Update(force: overrideForce,
                      info: updateInfo,
                      url: URL(string: ipaUrlString ?? ""),
                      to: latest)
        
    }
    
    enum CodingKeys: String, CodingKey {
        case versionName, isForce, ipaUrlString = "downloadAddress", updateInfo = "updateInformation"
        case minimum
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latest = try container.decode(Version.self, forKey: .versionName)
        minimum = try container.decodeIfPresent(Version.self, forKey: .minimum)
        isForce = try container.decode(Bool.self, forKey: .isForce)
        
        ipaUrlString = try container.decodeIfPresent(String.self, forKey: .ipaUrlString)
        updateInfo = try container.decodeIfPresent(String.self, forKey: .updateInfo)
    }
    
    /// 目前已是最新版本？
    public var isTheLatestVersion: Bool { current >= latest }
    
    
    
    public struct Update {
        
        private let forcely: Bool
        
        let updateInfo: String?
        
        public let ipaUrl: URL?
        
        /// 更新到的版本
        public let to: Version
        
        
        public init(force: Bool, info: String?, url: URL?, to: Version) {
            self.forcely = force
            self.updateInfo = info
            self.ipaUrl = url
            self.to = to
        }
        
        /// 是否需要强更
        public func byForce() -> Bool { forcely }
        
        /// 更新内容
        public func news() -> String {
            updateInfo?.replacingOccurrences(of: "\\n", with: "\n") ?? ""
        }
    
    }
    
}
