//
//  Date+Format.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

extension Date {

    var shortDateTimeString: String {
        return DateFormatter.localizedString(from: self,
                                             dateStyle: .short,
                                             timeStyle: .short)
    }

}
