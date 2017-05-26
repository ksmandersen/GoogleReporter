//
//  GoogleReporter.swift
//  GoogleReporter
//
//  Created by Kristian Andersen on 22/05/2017.
//  Copyright © 2017 Kristian Co. All rights reserved.
//

import UIKit

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
    
    private lazy var userAgent: String = {
        let currentDevice = UIDevice.current
        let osVersion = currentDevice.systemVersion.replacingOccurrences(of: ".", with: "_")
        return "Mozilla/5.0 (\(currentDevice.model); CPU iPhone OS \(osVersion) like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13T534YI"
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
        let size = UIScreen.main.bounds.size
        return "\(size.width)x\(size.height)"
    }()
}
