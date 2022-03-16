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
    
    private var activityIndicator = UIActivityIndicatorView()

    func configure() {
        tableView.rowHeight = 300
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.frame = CGRect(x: CGFloat(0), y: CGFloat(20), width: tableView.bounds.width, height: CGFloat(44))
        activityIndicator.hidesWhenStopped = true
        
        tableView.tableFooterView = activityIndicator
    }
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
        tableView.tableFooterView?.isHidden = false
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        tableView.tableFooterView = nil
    }
}
