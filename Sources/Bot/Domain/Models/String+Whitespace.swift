//
//  String+Whitespace.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

extension String {

    var isHashtag: Bool {
        return self.hasPrefix("#")
    }

    var withoutHashPrefix: String {
        guard self.isHashtag else { return self }
        return String(self.dropFirst())
    }

    var withoutAtPrefix: String {
        guard self.hasPrefix("@") else { return self }
        return String(self.dropFirst())
    }

    var withoutSpaces: String {
        let string = self.trimmingCharacters(in: .whitespaces)
        return string.replacingOccurrences(of: " ", with: "")
    }

    var withoutSpacesOrNewlines: String {
        var string = self.trimmingCharacters(in: .whitespacesAndNewlines)
        string = string.replacingOccurrences(of: " ", with: "")
        return string.replacingOccurrences(of: "\n", with: "")
    }

    var trimmedForSingleLine: String {
        let string = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return string.self.replacingOccurrences(of: "\n", with: " ")
    }

    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
