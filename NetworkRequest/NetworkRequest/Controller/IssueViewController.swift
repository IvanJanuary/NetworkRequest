//
//  IssureViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 16.08.2023.
//

import UIKit

class IssueViewController: UIViewController, UISearchBarDelegate {
    
    var searchText: String = ""
    var page = 1
    var isLoading = true

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var issues: [Issue] = []

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
        issues = []
        searchText = searchBarText
        
        searchIssues(withQuery: searchText, page: "\(page)", type: IssueSearchResult.self)
    }
    
    private func searchIssues<T: SearchResult>(withQuery query: String, page: String, type: T.Type) {
        guard !query.isEmpty else {
            issues.removeAll()
            tableView.reloadData()
            return
        }
        
        isLoading = true
        activityIndicator.startAnimating()
        
        let api = "https://api.github.com/search/issues?page=1&per_page=10&q=\(query)" 
        let helper = GitHubHelper()
        helper.search(withQuery: api, type: IssueSearchResult.self) { [weak self] searchItems in
            guard let self = self else {
                return
            }
            self.issues.append(contentsOf: searchItems as? [Issue] ?? [])
            self.tableView.reloadData()
            
            self.isLoading = false
            self.activityIndicator.stopAnimating()
        }
    }
}

extension IssueViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let issue = issues[indexPath.row]
        cell.textLabel?.text = issue.title
        cell.detailTextLabel?.text = issue.url ?? "No description available"
        return cell
    }
}

