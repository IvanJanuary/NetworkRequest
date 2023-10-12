//
//  GitHubHelper.swift
//  NetworkRequest
//
//  Created by Ivan on 05.10.2023.
//

import Foundation

struct GitHubHelper {
    
    func search<T: SearchResult>(withQuery urlString: String, type: T.Type, completion: @escaping([SearchItem]) -> Void) {
        
        guard let url = URL(string: urlString) else { fatalError("some Error") }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let searchResult = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(searchResult.items)
                }
            } catch {
                print("Decoding error JSON: \(error)")
            }
        }
        task.resume()
    }
}
