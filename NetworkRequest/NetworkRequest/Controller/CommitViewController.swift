//
//  CommitViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 19.09.2023.
//

import UIKit

class CommitViewController: UIViewController, UISearchBarDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var searchText: String = ""
    var page = 1

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var commits: [CommitItem] = []
    

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
        commits = []
        searchText = searchBarText
        
        searchCommits(withQuery: searchText, page: "\(page)", type: CommitSearchResult.self)
    }
    
    private func searchCommits<T: SearchResult>(withQuery query: String, page: String, type: T.Type) {
        guard !query.isEmpty else {
            commits.removeAll()
            tableView.reloadData()
            return
        }
        
        activityIndicator.startAnimating()
        
        let api = "https://api.github.com/search/commits?page=1&per_page=20&q=\(query)"
        let helper = GitHubHelper()
        helper.search(withQuery: api, type: CommitSearchResult.self) { [weak self] searchItems in
            guard let self = self else {
                return
            }
            self.commits.append(contentsOf: searchItems as? [CommitItem] ?? [])
            self.tableView.reloadData()
            
            self.activityIndicator.stopAnimating()
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row + 1) % 10 == 0  && indexPath.row == (page * 10) - 1 {
            page += 1
            searchCommits(withQuery: searchText, page: "\(page)", type: CommitSearchResult.self)
        }
    }
}
    

    
    
    
