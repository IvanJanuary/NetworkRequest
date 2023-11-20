//
//  ViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 02.08.2023.
//

import UIKit

class RepositoryViewController: UIViewController, UISearchBarDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var searchText: String = ""
    var page = 1


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var repositories: [Repository] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        self.view.addSubview(activityIndicator)
        
        activityIndicatorConstraint()
    }
    
    func activityIndicatorConstraint() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
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
        
        activityIndicator.startAnimating()
        
        let api = "https://api.github.com/search/repositories?page=1&per_page=20&q=\(query)"
        let helper = GitHubHelper()
        helper.search(withQuery: api, type: RepositorySearchResult.self) { [weak self] searchItems in
            guard let self = self else {
                return
            }
            self.repositories.append(contentsOf: searchItems as? [Repository] ?? [])
            self.tableView.reloadData()
            
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
    
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if (indexPath.row + 1) % 10 == 0  && indexPath.row == (page * 10) - 1 {
                page += 1
                searchRepositories(withQuery: searchText, page: "\(page)", type: RepositorySearchResult.self)
            }
        }
}
