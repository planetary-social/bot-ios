//
//  File.swift
//  
//
//  Created by Martin Dutra on 28/12/21.
//

import Foundation

protocol BotService {

    func everyone(completion: @escaping (([KeyValue]) -> Void))

}
