//
//  ViewController.swift
//  NewsApp
//
//  Created by Мария Газизова on 02.03.2022.
//
// api key = 687e62c563ac4342959cf12264aabeed

import UIKit

class NewsViewController: UIViewController {
    private var newsForToday = NewsGroup.emptyNews()
    
    private var newsView: NewsView! {
        guard isViewLoaded else { return nil }
        return (view as! NewsView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        NewsGroup.updateNews() { complete in
            self.newsForToday = complete
            DispatchQueue.main.async {
                self.newsView.tableView.reloadData()
            }
        }
    }
}

extension NewsViewController {
    func configure() {
        newsView.tableView.delegate = self
        newsView.tableView.dataSource = self
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsForToday.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell")
        cell?.textLabel?.text = newsForToday.news[indexPath.row].title
        return cell!
    }
}
