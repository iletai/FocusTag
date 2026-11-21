import CoreNFC
import CryptoKit
import Foundation

/// Reads the UID of a physical NFC tag and returns its SHA-256 hex digest.
/// Only the hash is ever stored, so the raw UID never touches disk.
@MainActor
final class NFCTagReader: NSObject {
    enum ReadError: Error {
        case unavailable
        case unsupported
        case timeout
        case cancelled

        /// User-facing text; nil when the user simply closed the sheet.
        var message: String? {
            switch self {
            case .unavailable: String(localized: "nfc_pairing.error.unavailable")
            case .unsupported: String(localized: "nfc_pairing.error.unsupported")
            case .timeout: String(localized: "nfc_pairing.error.timeout")
            case .cancelled: nil
            }
        }
    }

    private var continuation: CheckedContinuation<String, Error>?

    static var isAvailable: Bool { NFCTagReaderSession.readingAvailable }

    /// Presents the system NFC sheet; throws `ReadError` when nothing usable was scanned.
    func scan(prompt: String) async throws -> String {
        guard Self.isAvailable else { throw ReadError.unavailable }
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self, queue: .main)
            session?.alertMessage = prompt
            session?.begin()
        }
    }

    nonisolated static func hash(uid: Data) -> String {
        SHA256.hash(data: uid).map { String(format: "%02x", $0) }.joined()
    }

    private func finish(_ result: Result<String, ReadError>) {
        continuation?.resume(with: result)
        continuation = nil
    }
}

extension NFCTagReader: NFCTagReaderSessionDelegate {
    nonisolated func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        let code = (error as? NFCReaderError)?.code
        let mapped: ReadError = code == .readerSessionInvalidationErrorSessionTimeout ? .timeout : .cancelled
        Task { @MainActor in self.finish(.failure(mapped)) }
    }

    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        let uid: Data? = switch tags.first {
        case .miFare(let tag): tag.identifier
        case .iso7816(let tag): tag.identifier
        case .iso15693(let tag): tag.identifier
        default: nil
        }
        guard let uid, !uid.isEmpty else {
            session.invalidate(errorMessage: String(localized: "nfc_pairing.error.unsupported"))
            Task { @MainActor in self.finish(.failure(.unsupported)) }
            return
        }
        session.invalidate()
        let digest = Self.hash(uid: uid)
        Task { @MainActor in self.finish(.success(digest)) }
    }
}
