//
//  APIService.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

protocol APIService {
    func everyone(completion: @escaping (([KeyValue], Error?) -> Void))
}
