import Foundation
import os.log

/// Structured logger equivalent to Timber usage in Android.
enum VerbumLogger {
    private static let logger = Logger(subsystem: "com.verbum.app", category: "Verbum")

    static func d(_ message: String, file: String = #file, function: String = #function) {
        logger.debug("[\(function)] \(message)")
    }

    static func i(_ message: String) {
        logger.info("\(message)")
    }

    static func w(_ message: String) {
        logger.warning("\(message)")
    }

    static func e(_ message: String, error: Error? = nil) {
        if let error {
            logger.error("\(message): \(error.localizedDescription)")
        } else {
            logger.error("\(message)")
        }
    }
}
