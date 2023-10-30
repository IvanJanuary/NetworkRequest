//
//  IssureViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 16.08.2023.
//

import UIKit

class IssueViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var issues: [Issue] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
        
    @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchIssues(withQuery: searchText, type: IssueSearchResult.self) //type: IssueSearchResult.self
    }
    
    private func searchIssues<T: SearchResult>(withQuery query: String, type: T.Type) {  //<T: SearchResult>  type: T.Type
        guard !query.isEmpty else {
            issues.removeAll()
            tableView.reloadData()
            return
        }
        
        let api = "https://api.github.com/search/issues?per_page=10&q=\(query)"
        let helper = GitHubHelper()
        helper.search(withQuery: api, type: IssueSearchResult.self) { [weak self] searchItems in
            guard let self = self else {
                return
            }
            self.issues = searchItems as? [Issue] ?? []
            self.tableView.reloadData()
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

