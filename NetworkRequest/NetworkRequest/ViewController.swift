//
//  ViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 02.08.2023.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var repositoryTabBarItem: UITabBarItem!
    @IBOutlet weak var issureTabBarItem: UITabBarItem!
    
    private var repositories: [Repository] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchRepositories(withQuery: searchText)
    }
    
    private func searchRepositories(withQuery query: String) {
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
                let searchResult = try decoder.decode(SearchResult.self, from: data)
                DispatchQueue.main.async {
                    self.repositories = searchResult.items
                    self.tableView.reloadData()
                }
            } catch {
                print("Decoding error JSON: \(error)")
            }
        }
        task.resume()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
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
