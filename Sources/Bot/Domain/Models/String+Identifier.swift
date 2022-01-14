//
//  File.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation
import CryptoKit

public extension String {

    static let null = "null"
    static let notLoggedIn = "not-logged-in"
    static let unsupported = "unsupported"

    // the first character of the identifier indicating
    // what kind of identifier this is
    var sigil: Sigil {
        if      self.hasPrefix(Sigil.blob.rawValue)         { return .blob }
        else if self.hasPrefix(Sigil.feed.rawValue)         { return .feed }
        else if self.hasPrefix(Sigil.message.rawValue)      { return .message }
        else                                                { return .unsupported }
    }

    // the base64 number between the sigil, marker, and algorithm
    var id: String {
        let components = self.components(separatedBy: ".")
        guard components.count == 2 else { return String.unsupported }
        let component = components[0] as String
        guard component.count > 1 else { return String.unsupported }
        guard component.hasSuffix("=") else { return String.unsupported }
        guard component.sigil != Sigil.unsupported else { return String.unsupported }
        let index = component.index(after: component.startIndex)
        return String(component[index...])
    }

    var idBytes: Data? {
        if !self.isValidIdentifier {
            #if DEBUG
            print("warning: invalid identifier:\(self)")
            #endif
            return nil
        }
        guard let data = Data(base64Encoded: self.id, options: .ignoreUnknownCharacters) else { return nil }
        return data
    }

    func hexEncodedString() -> String {
        guard let bytes = self.idBytes else {
            return ""
        }

        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(bytes.count * 2)

        for byte in bytes {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.append(hexDigits[index1])
            hexChars.append(hexDigits[index2])
        }

        return String(utf16CodeUnits: hexChars, count: hexChars.count)
    }

    // the trailing suffix indicating how the id is encoded
    var algorithm: Algorithm {
        if      self.hasSuffix(Algorithm.sha256.rawValue)   { return .sha256 }
        else if self.hasSuffix(Algorithm.ed25519.rawValue)  { return .ed25519 }
        else if self.hasSuffix(Algorithm.ggfeed.rawValue)   { return .ggfeed }
        else                                                { return .unsupported }
    }

    var isValidIdentifier: Bool {
        return self.sigil != .unsupported &&
            self.id != String.unsupported &&
            self.algorithm != .unsupported
    }

    var isBlob: Bool {
        return self.sigil == .blob
    }

    // TODO: this is a iOS13 specific way to do sha25 hashing....
    // TODO: also it retuns a hex string but i have spent to much time on this already
    var sha256hash: String {
        if #available(iOS 13.0, *) {
            let input = self.data(using: .utf8)!
            let hashed = SHA256.hash(data: input)
            // using description is silly but i couldnt figure out https://developer.apple.com/documentation/cryptokit/sha256digest Accessing Underlying Storage
            let descr = hashed.description
            let prefix = "SHA256 digest: "
            guard descr.hasPrefix(prefix) else { fatalError("oh gawd whhyyyy") }
            return String(descr.dropFirst(prefix.count))
        } else {
            // https://augmentedcode.io/2018/04/29/hashing-data-using-commoncrypto/ ?
            fatalError("TODO: get CommonCrypto method to work or find another swift 5 method")
        }
    }
}
