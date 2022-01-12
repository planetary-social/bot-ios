//
//  ContentTypeable.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

/// Required protocol to allow a model to be encoding for `API.publish()`.
/// Any new models that need to be published MUST inherit this protocol.
public protocol ContentTypeable {

    var type: ContentType { get }
    
}
