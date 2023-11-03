//
//  CommitViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 19.09.2023.
//

import UIKit

class CommitViewController: UIViewController, UISearchBarDelegate {
    
    var buttonMore = UIButton()
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
        
        buttonMore = UIButton(type: .roundedRect)
        buttonMore.frame = CGRect(x: 0, y: 0, width: 64, height: 35)
        buttonMore.backgroundColor = .systemTeal
        buttonMore.layer.cornerRadius = 5
        buttonMore.translatesAutoresizingMaskIntoConstraints = false
        buttonMore.setTitle("More", for: .normal)
        buttonMore.setTitleColor(UIColor.white, for: .normal)
    
        buttonMore.addTarget(self, action: #selector(pressButton), for: .touchUpInside)
        self.view.addSubview(buttonMore)
        
        buttonMoreConstraint()
    }
    
    func buttonMoreConstraint() {
        //buttonMore.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 150).isActive = true
        buttonMore.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4).isActive = true
        buttonMore.heightAnchor.constraint(equalToConstant: 35).isActive = true
        buttonMore.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonMore.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
    }
    
    @objc func pressButton(sender: UIButton) {
        print("Button is pressed")
        page += 1
        searchCommits(withQuery: searchText, page: "\(page)", type: CommitSearchResult.self)
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
        
        let api = "https://api.github.com/search/commits?page=1&per_page=10&q=\(query)"
        let helper = GitHubHelper()
        helper.search(withQuery: api, type: CommitSearchResult.self) { [weak self] searchItems in
            guard let self = self else {
                return
            }
            self.commits.append(contentsOf: searchItems as? [CommitItem] ?? [])
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
    
    
    
