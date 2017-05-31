//
//  GoogleReporter.swift
//  GoogleReporter
//
//  Created by Kristian Andersen on 22/05/2017.
//  Copyright © 2017 Kristian Co. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import AppKit
    import Foundation
#endif

extension Dictionary {
    func combinedWith(_ other: [Key: Value]) -> [Key: Value] {
        var dict = self
        for (key, value) in other {
            dict[key] =  value
        }
        return dict
    }
}

public class GoogleReporter {
    public static let shared = GoogleReporter()
    
    public var quietMode = true
    
    private static let baseURL = URL(string: "https://www.google-analytics.com/")!
    private static let identifierKey = "co.kristian.GoogleReporter.uniqueUserIdentifier"
    
    private var trackerId: String?
    
    private init() {}
    
    public func configure(withTrackerId trackerId: String) {
        self.trackerId = trackerId
    }
    
    public func screenView(_ name: String, parameters: [String: String] = [:]) {
        let data = parameters.combinedWith(["cd": name])
        send("screenView", parameters: data)
    }
    
    public func event(_ category: String, action: String, label: String = "",
                      parameters: [String: String] = [:]) {
        let data = parameters.combinedWith([
            "ec": category,
            "ea": action,
            "el": label
            ])
        
        send("event", parameters: data)
    }
    
    public func exception(_ description: String, isFatal: Bool,
                          parameters: [String: String] = [:]) {
        let data = parameters.combinedWith([
            "exd": description,
            "exf": String(isFatal)
            ])
        
        send("exception", parameters: data)
    }
    
    private func send(_ type:  String, parameters: [String: String]) {
        guard let trackerId = trackerId else {
            fatalError("You must set your tracker ID UA-XXXXX-XX with GoogleReporter.configure()")
        }
        
        let queryArguments: [String: String] = [
            "tid": trackerId,
            "aid": appIdentifier,
            "cid": uniqueUserIdentifier,
            "an": appName,
            "av": formattedVersion,
            "ua": userAgent,
            "ul": userLanguage,
            "sr": screenResolution,
            "v": "1",
            "t": type
        ]
        
        let arguments = queryArguments.combinedWith(parameters)
        let url = GoogleReporter.generateUrl(with: arguments)
        
        if !quietMode {
            print("Sending GA Report: ", url.absoluteString)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { _, _, error in
            if let errorResponse = error?.localizedDescription {
                print("Failed to deliver GA Request. ", errorResponse)
            }
        }
        
        task.resume()
    }
    
    private static func generateUrl(with parameters: [String: String]) -> URL {
        let characterSet = CharacterSet.urlPathAllowed
        
        let joined = parameters.reduce("collect?") { path, query in
            let value = query.value.addingPercentEncoding(withAllowedCharacters: characterSet)
            return String(format: "%@%@=%@&", path, query.key, value ?? "")
        }
        
        // Trim the trailing &
        let path = joined.substring(to: joined.characters.index(before: joined.endIndex))
        
        // Make sure we generated a valid URL
        guard let url = URL(string: path, relativeTo: baseURL) else {
            fatalError("Failed to generate a valid GA url")
        }
        
        return url
    }
    
    private lazy var uniqueUserIdentifier: String = {
        let defaults = UserDefaults.standard
        guard let identifier = defaults.string(forKey: GoogleReporter.identifierKey) else {
            let identifier = UUID().uuidString
            defaults.set(identifier, forKey: GoogleReporter.identifierKey)
            defaults.synchronize()
            
            if !self.quietMode {
                print("New GA user with identifier: ", identifier)
            }
            
            return identifier
        }
        
        return identifier
    }()
    
    public lazy var userAgent: String = {
        #if os(iOS) || os(tvOS) || os(watchOS)
            let currentDevice = UIDevice.current
            let osVersion = currentDevice.systemVersion.replacingOccurrences(of: ".", with: "_")
            return "Mozilla/5.0 (\(currentDevice.model); CPU iPhone OS \(osVersion) like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13T534YI"
        #elseif os(OSX)
            let osVersion = ProcessInfo.processInfo.operatingSystemVersionString.replacingOccurrences(of: ".", with: "_")
            
            return "\(try! self.sysctlString(levels: CTL_HW, HW_MODEL)); \(osVersion))"
        #endif
    }()
    
    private lazy var appName: String = {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }()
    
    private lazy var appIdentifier: String = {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    }()
    
    private lazy var appVersion: String = {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }()
    
    private lazy var appBuild: String = {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }()
    
    private lazy var formattedVersion: String = {
        return "\(self.appVersion) (\(self.appBuild))"
    }()
    
    private lazy var userLanguage: String = {
        guard let locale = Locale.preferredLanguages.first, locale.characters.count > 0 else {
            return "(not set)"
        }
        
        return locale
    }()
    
    private lazy var screenResolution: String = {
        #if os(iOS) || os(tvOS) || os(watchOS)
            let size = UIScreen.main.bounds.size
        #elseif os(OSX)
            let size = NSScreen.main()!.frame.size
        #endif
        
        return "\(size.width)x\(size.height)"
    }()
    
    /* So apparently it's pretty complex to get the model identifier on macOS (e.g. MacBookPro11,1).
       Need to use the sysctl function. The following are some wrapper functions around sysctl
       which come from here: 
       https://github.com/mattgallagher/CwlUtils/blob/af275791ae3dcfe9ab18a4593c0c13c464498504/Sources/CwlUtils/CwlSysctl.swift
    */
    #if os(OSX)
    private func sysctlString(levels: Int32...) throws -> String {
        return try stringFromSysctl(levels: levels)
    }
    
    public func sysctlLevels(fromName: String) throws -> [Int32] {
        var levelsBufferSize = Int(CTL_MAXNAME)
        var levelsBuffer = Array<Int32>(repeating: 0, count: levelsBufferSize)
        try levelsBuffer.withUnsafeMutableBufferPointer { (lbp: inout UnsafeMutableBufferPointer<Int32>) throws in
            try fromName.withCString { (nbp: UnsafePointer<Int8>) throws in
                guard sysctlnametomib(nbp, lbp.baseAddress, &levelsBufferSize) == 0 else {
                    throw POSIXErrorCode(rawValue: errno).map { SysctlError.posixError($0) } ?? SysctlError.unknown
                }
            }
        }
        if levelsBuffer.count > levelsBufferSize {
            levelsBuffer.removeSubrange(levelsBufferSize..<levelsBuffer.count)
        }
        return levelsBuffer
    }
    
    private func stringFromSysctl(levels: [Int32]) throws -> String {
        let optionalString = try sysctl(levels: levels).withUnsafeBufferPointer() { dataPointer -> String? in
            dataPointer.baseAddress.flatMap { String(validatingUTF8: $0) }
        }
        guard let s = optionalString else { throw SysctlError.malformedUTF8 }
        return s
    }
    
    private func sysctl(levels: [Int32]) throws -> [Int8] {
        return try levels.withUnsafeBufferPointer() { levelsPointer throws -> [Int8] in
            // Preflight the request to get the required data size
            var requiredSize = 0
            let preFlightResult = Darwin.sysctl(UnsafeMutablePointer<Int32>(mutating: levelsPointer.baseAddress), UInt32(levels.count), nil, &requiredSize, nil, 0)
            if preFlightResult != 0 {
                throw POSIXErrorCode(rawValue: errno).map { SysctlError.posixError($0) } ?? SysctlError.unknown
            }
            
            // Run the actual request with an appropriately sized array buffer
            let data = Array<Int8>(repeating: 0, count: requiredSize)
            let result = data.withUnsafeBufferPointer() { dataBuffer -> Int32 in
                return Darwin.sysctl(UnsafeMutablePointer<Int32>(mutating: levelsPointer.baseAddress), UInt32(levels.count), UnsafeMutableRawPointer(mutating: dataBuffer.baseAddress), &requiredSize, nil, 0)
            }
            if result != 0 {
                throw POSIXErrorCode(rawValue: errno).map { SysctlError.posixError($0) } ?? SysctlError.unknown
            }
            
            return data
        }
    }
    
    public enum SysctlError: Error {
        case unknown
        case malformedUTF8
        case invalidSize
        case posixError(POSIXErrorCode)
    }
    #endif
}
