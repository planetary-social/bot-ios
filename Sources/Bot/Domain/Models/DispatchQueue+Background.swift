//
//  DispatchQueue+Background.swift
//  
//
//  Created by Martin Dutra on 11/1/22.
//

import Foundation

extension DispatchQueue {

    static var background: DispatchQueue {
        return DispatchQueue.global(qos: .background)
    }
    
}
