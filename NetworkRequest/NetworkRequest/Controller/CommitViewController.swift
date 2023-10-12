//
//  CommitViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 19.09.2023.
//

import UIKit

class CommitViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var commits: [CommitItem] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }

    @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchCommits(withQuery: searchText, type: CommitSearchResult.self) //type: CommitSearchResult.self
    }
    
    private func searchCommits<T: SearchResult>(withQuery query: String, type: T.Type) { //<T: SearchResult>  type: T.Type
        guard !query.isEmpty else {
            commits.removeAll()
            tableView.reloadData()
            return
        }
        
        let api = "https://api.github.com/search/commits?q=\(query)"
        let helper = GitHubHelper()
        helper.search(withQuery: api, type: CommitSearchResult.self) { [weak self] searchItems in
            guard let self = self else {
                return
            }
            self.commits = searchItems as? [CommitItem] ?? [] 
            self.tableView.reloadData()
        }
    }
}

extension CommitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommitTableViewCell
        
        let commit = commits[indexPath.row]
        
        cell.commitLabel.text = "Commit: " + commit.commit.message
        cell.urlLabel.text = "Url: " + (commit.url ?? "No description available")
        cell.authorLabel.text = "Author: " + commit.commit.author.name
       
        if let repository = commit.repository {
            cell.repositoryLabel.text = "Repository: " + repository.name
        } else {
            cell.repositoryLabel.text = "No repository available"
        }
        return cell
    }
   
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 300
          }
          func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
          }
}
    
    
    
