//
//  PirateLogger.swift
//  PirateWallet
//
//  Created by Lokesh on 13/09/24.
//

import Foundation

/**
 Represents what's expected from a logging entity
 */
public protocol Logger {
    
    func debug(_ message: String, file: StaticString, function: StaticString, line: Int)
    
    func info(_ message: String, file: StaticString, function: StaticString, line: Int)
    
    func event(_ message: String, file: StaticString, function: StaticString, line: Int)
    
    func warn(_ message: String, file: StaticString, function: StaticString, line: Int)
    
    func error(_ message: String, file: StaticString, function: StaticString, line: Int)
    
}

var logger: Logger?

class LoggerProxy {
    
    static func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        logger?.debug(message, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        logger?.info(message, file: file, function: function, line: line)
    }
    
    static func event(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        logger?.event(message, file: file, function: function, line: line)
    }
    
    static func warn(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        logger?.warn(message, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        logger?.error(message, file: file, function: function, line: line)
    }
    
}


class PirateLogger: Logger {
    enum LogLevel: Int {
        case debug
        case error
        case warning
        case event
        case info
    }
    
    enum LoggerType {
        case printerLog
    }
    
    var level: LogLevel
    var loggerType: LoggerType
    
    init(logLevel: LogLevel, type: LoggerType = .printerLog) {
        self.level = logLevel
        self.loggerType = type
    }
    
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        guard level.rawValue == LogLevel.debug.rawValue else { return }
        log(level: "DEBUG 🐞", message: message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        guard level.rawValue <= LogLevel.error.rawValue else { return }
        log(level: "ERROR 💥", message: message, file: file, function: function, line: line)
    }
    
    func warn(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
           guard level.rawValue <= LogLevel.warning.rawValue else { return }
           log(level: "WARNING ⚠️", message: message, file: file, function: function, line: line)
    }

    func event(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        guard level.rawValue <= LogLevel.event.rawValue else { return }
        log(level: "EVENT ⏱", message: message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        guard level.rawValue <= LogLevel.info.rawValue else { return }
        log(level: "INFO ℹ️", message: message, file: file, function: function, line: line)
    }
    
    private func log(level: String, message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        let fileName = (String(describing: file) as NSString).lastPathComponent
        switch loggerType {
        case .printerLog:
            print("[\(level)] \(fileName) - \(function) - line: \(line) -> \(message)")
        }
    }
}
