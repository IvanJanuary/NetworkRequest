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
        searchIssues(withQuery: searchText)
    }
    
    private func searchIssues(withQuery query: String) {
        guard !query.isEmpty else {
            issues.removeAll()
            tableView.reloadData()
            return
        }
        
        let api = "https://api.github.com/search/issues?q=\(query)" 
        guard let url = URL(string: api) else { fatalError("some Error") }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let searchResult = try decoder.decode(IssueSearchResult.self, from: data)
                DispatchQueue.main.async {
                    self.issues = searchResult.items
                    self.tableView.reloadData()
                }
            } catch {
                print("JSON decoding error: \(error)")
            }
        }
        task.resume()
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

