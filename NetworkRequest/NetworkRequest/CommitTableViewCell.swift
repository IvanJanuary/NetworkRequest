//
//  CommitTableViewCell.swift
//  NetworkRequest
//
//  Created by Ivan on 19.09.2023.
//

import UIKit

class CommitTableViewCell: UITableViewCell {

    @IBOutlet weak var commitLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var repositoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
