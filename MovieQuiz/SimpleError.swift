import Foundation

final class SimpleError: NSError, @unchecked Sendable {
    override var localizedDescription: String {
        return domain
    }
    convenience init(_ message: String) {
        self.init(domain: message, code: 0, userInfo: [:])
    }
}
