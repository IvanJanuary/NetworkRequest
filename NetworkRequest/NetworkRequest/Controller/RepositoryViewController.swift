//
//  ViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 02.08.2023.
//

import UIKit

class RepositoryViewController: UIViewController, UISearchBarDelegate {
    
    var searchText: String = ""
    var page = 1
    var isLoading = true

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var repositories: [Repository] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        activityIndicatorConstraint()
    }
    
    func activityIndicatorConstraint() {
        activityIndicator.widthAnchor.constraint(equalToConstant: 25).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 25).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
    }

    @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else {
            return
        }
        page = 1
        repositories = []
        searchText = searchBarText
        
        searchRepositories(withQuery: searchText, page: "\(page)", type: RepositorySearchResult.self)
    }

    private func searchRepositories<T: SearchResult>(withQuery query: String, page: String, type: T.Type) {
        guard !query.isEmpty else {
            repositories.removeAll()
            tableView.reloadData()
            return
        }
        
        isLoading = true
        activityIndicator.startAnimating()
        
        let api = "https://api.github.com/search/repositories?page=1&per_page=10&q=\(query)"
        let helper = GitHubHelper()
        helper.search(withQuery: api, type: RepositorySearchResult.self) { [weak self] searchItems in
            guard let self = self else {
                return
            }
            self.repositories.append(contentsOf: searchItems as? [Repository] ?? [])
            self.tableView.reloadData()
            
            self.isLoading = false
            self.activityIndicator.stopAnimating()
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
