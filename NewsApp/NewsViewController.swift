//
//  ViewController.swift
//  NewsApp
//
//  Created by Мария Газизова on 02.03.2022.
//

import UIKit
import Kingfisher
import SafariServices

class NewsViewController: UIViewController {
    private var newsForToday: NewsGroup?
    private let newsManager = NewsApiManager()
    
    private var newsView: NewsView! {
        guard isViewLoaded else { return nil }
        return (view as! NewsView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        newsManager.fetchNews(completion: handleNewsResult)
    }
    
    func handleNewsResult(result: Result<NewsGroup, Error>) {
        switch result {
        case .success(let news):
            newsForToday = news
            DispatchQueue.main.async {
                self.newsView.tableView.reloadData()
            }
        case .failure(let error):
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            alert.addAction(UIAlertAction(title: "Try again", style: .default) {(action) -> Void in
                self.newsManager.fetchNews(completion: self.handleNewsResult)
            })
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension NewsViewController {
    func configure() {
        newsView.tableView.delegate = self
        newsView.tableView.dataSource = self
        newsView.configure()
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let news = newsForToday else { return 0 }
        
        return news.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as? NewsTableViewCell else { return UITableViewCell()}
        guard let news = newsForToday else { return cell }
        
        cell.configure(withText: news.articles[indexPath.row].title, byAuthor: news.articles[indexPath.row].author ?? "")
        
        if let urlToImage = news.articles[indexPath.row].urlToImage, let url = URL(string: urlToImage) {
            cell.newsImage.kf.setImage(with: url)
        }
        return cell
    }
}

extension NewsViewController: SFSafariViewControllerDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let news = newsForToday, let url = URL(string: news.articles[indexPath.row].url) else { return () }
        
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
        svc.delegate = self
    }
}
