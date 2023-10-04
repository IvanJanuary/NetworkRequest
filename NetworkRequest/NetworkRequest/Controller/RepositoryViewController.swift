//
//  ViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 02.08.2023.
//

import UIKit

class RepositoryViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var repositories: [Repository] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
        
    @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchRepositories(withQuery: searchText, type: RepositorySearchResult.self) //type: RepositorySearchResult.self
    }
                                                                            
    private func searchRepositories<T: SearchResult>(withQuery query: String, type: T.Type) { //<T: SearchResult> type: T.Type
        guard !query.isEmpty else {
            repositories.removeAll()
            tableView.reloadData()
            return
        }
        
        let api = "https://api.github.com/search/repositories?q=\(query)"
        guard let url = URL(string: api) else { fatalError("some Error") }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let searchResult = try decoder.decode(T.self, from: data) // T.self instead RepositorySearchResult.self
                DispatchQueue.main.async {
                    self.repositories = searchResult.items as? [Repository] ?? [] // unwrapped as? [Repository] ?? []
                    self.tableView.reloadData()
                }
            } catch {
                print("Decoding error JSON: \(error)")
            }
        }
        task.resume()
    }
}

extension RepositoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let repository = repositories[indexPath.row]
        cell.textLabel?.text = repository.name
        cell.detailTextLabel?.text = repository.description ?? "No description available"
        return cell
    }
}
