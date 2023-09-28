//
//  Commit.swift
//  NetworkRequest
//
//  Created by Ivan on 19.09.2023.
//

import Foundation

struct CommitItem: Codable {
    let commit: Commit
    let url: String?
    let repository: Repository?
    
    struct Commit: Codable {
        let message: String
        let author: Author
    }
    
    struct Author: Codable {
        let name: String
    }
    
    struct Repository: Codable {
        let name: String
    }
}
