//
//  SearchResult.swift
//  NetworkRequest
//
//  Created by Ivan on 04.10.2023.
//

import Foundation

protocol SearchResult: Codable {
    associatedtype T: SearchItem
    var items: [T] { get }
}
