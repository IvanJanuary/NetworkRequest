//
//  ViewController.swift
//  NetworkRequest
//
//  Created by Ivan on 02.08.2023.
//

import UIKit

class RepositoryViewController: UIViewController, UISearchBarDelegate {
    
    var buttonMore = UIButton()
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
        searchRepositories(withQuery: searchText, page: "\(page)", type: RepositorySearchResult.self)
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
        
        let api = "https://api.github.com/search/repositories?page=1&per_page=10&q=\(query)"
        let helper = GitHubHelper()
        helper.search(withQuery: api, type: RepositorySearchResult.self) { [weak self] searchItems in
            guard let self = self else {
                return
            }
            self.repositories.append(contentsOf: searchItems as? [Repository] ?? [])
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
