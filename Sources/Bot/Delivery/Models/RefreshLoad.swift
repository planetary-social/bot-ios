//
//  RefreshLoad.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

public enum RefreshLoad: Int, CaseIterable {
    case tiny = 500
    case short = 15000
    case medium = 45000
    case long = 100000
}
