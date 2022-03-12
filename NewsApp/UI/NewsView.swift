//
//  NewsView.swift
//  NewsApp
//
//  Created by Мария Газизова on 02.03.2022.
//

import UIKit

class NewsView: UIView {
    @IBOutlet weak var tableLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    func configure() {
        tableView.rowHeight = 300
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
    }
}
