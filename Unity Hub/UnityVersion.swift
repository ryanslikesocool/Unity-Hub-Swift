//
//  UnityVersion.swift
//  Unity Hub
//
//  Created by Ryan Boyer on 9/23/20.
//

import Foundation
import AppKit

struct UnityVersion {
    let version: String
    var major: Int
    var minor: Int
    var update: Int
    var channel: String
    var iteration: Int

    // a: alpha
    // b: beta
    // f: final (official)
    // p: patch
    // c: china
    static let versionRegex = try! NSRegularExpression(pattern: #"^(\d+)\.(\d+)\.(\d+)([a|b|f|p|c])(\d+)"#)

    init(_ version: String) {
        self.version = version
        self.major = 0
        self.minor = 0
        self.update = 0
        self.channel = ""
        self.iteration = 0

        UnityVersion.versionRegex.enumerateMatches(in: version, options: [], range: NSRange(0 ..< version.count)) { (match, _, stop) in
            guard let match = match else { return }
            
            if match.numberOfRanges == 6,
               let range1 = Range(match.range(at: 1), in: version),
               let range2 = Range(match.range(at: 2), in: version),
               let range3 = Range(match.range(at: 3), in: version),
               let range4 = Range(match.range(at: 4), in: version),
               let range5 = Range(match.range(at: 5), in: version) {
                self.major = Int(String(version[range1])) ?? 0
                self.minor = Int(String(version[range2])) ?? 0
                self.update = Int(String(version[range3])) ?? 0
                self.channel = String(version[range4])
                self.iteration = Int(String(version[range5])) ?? 0
                stop.pointee = true
            } else {
                print("UnityVersion \(version) is not a valid unity version")
            }
        }
    }

    func getBranch() -> String {
        return "\(major).\(minor)"
    }

    func compare(other: UnityVersion) -> Int {
        if major == other.major {
            if minor == other.minor {
                if update == other.update {
                    if channel == other.channel {
                        if iteration == other.iteration {
                            return 0
                        }
                        return iteration > other.iteration ? 1 : -1
                    }
                    return channel > other.channel ? 1 : -1
                }
                return update > other.update ? 1 : -1
            }
            return minor > other.minor ? 1 : -1
        }
        return major > other.major ? 1 : -1
    }

    static func isOfficial(version: String) -> Bool {
        return isCorrectChannel(version: version, channelChar: "f");
    }

    static func isAlpha(version: String) -> Bool {
        return isCorrectChannel(version: version, channelChar: "a");
    }

    static func isBeta(version: String) -> Bool {
        return isCorrectChannel(version: version, channelChar: "b");
    }

    static func isCorrectChannel(version: String, channelChar: String) -> Bool {
        let regexMatchers = UnityVersion.versionRegex.matches(in: version, options: [], range: NSRange(0 ..< version.count))
        return String(describing: regexMatchers[4]) == channelChar
    }

    static func isValid(version: String) -> Bool {
        let regexMatchers = UnityVersion.versionRegex.matches(in: version, options: [], range: NSRange(0 ..< version.count))
        return regexMatchers.count == 6
    }
}