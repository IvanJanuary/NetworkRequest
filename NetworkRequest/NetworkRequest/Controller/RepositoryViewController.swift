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
        
        let api = "https://api.github.com/search/repositories?per_page=10&q=\(query)"
        let helper = GitHubHelper()
        helper.search(withQuery: api, type: RepositorySearchResult.self) { [weak self] searchItems in
            guard let self = self else {
                return
            }
        self.repositories = searchItems as? [Repository] ?? []
        self.tableView.reloadData()
        }
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
