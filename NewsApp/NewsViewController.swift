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
    private var newsForToday: [NewsModel] = []
    private let newsManager = NewsApiManager()
    
    // for pagination
    private var isDataLoading = false
    private var pageNumber = 1
    private let pageSize = 10
    private var totalResult: Int?
    private var didLoadAllNews = false {
        didSet {
            didLoadAllNews ? newsView.stopActivityIndicator() : newsView.startActivityIndicator()
        }
    }
    
    private var newsView: NewsView! {
        guard isViewLoaded else { return nil }
        return (view as! NewsView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        newsView.startActivityIndicator()

        newsManager.fetchNews(pageNumber: pageNumber, pageSize: pageSize) { [weak self] result in
            self?.handleNewsResult(result: result)
        }
    }
    
    private func configure() {
        newsView.tableView.delegate = self
        newsView.tableView.dataSource = self
        newsView.configure()
    }
    
    private func handleNewsResult(result: Result<NewsGroup, CustomError>) { 
        switch result {
        case .success(let news):
            newsForToday.append(contentsOf: news.articles ?? [])
            totalResult = news.totalResults
            if let totalResult = totalResult,
               totalResult <= newsForToday.count {
                didLoadAllNews = true
            }

            DispatchQueue.main.async {
                self.newsView.tableView.reloadData()
            }
        case .failure(let error):
            showAlert(error: error)
        }
    }
    
    private func showAlert(error: CustomError) {
        let alert = UIAlertController(title: "Error", message: error.errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        alert.addAction(UIAlertAction(title: "Try again", style: .default) {(action) -> Void in
            self.newsManager.fetchNews(pageNumber: self.pageNumber, pageSize: self.pageSize) { [weak self] result in
                self?.handleNewsResult(result: result)
            }
        })
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsForToday.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as? NewsTableViewCell else { return UITableViewCell() }

        cell.configure(withText: newsForToday[indexPath.row].title, byAuthor: newsForToday[indexPath.row].author ?? "")

        if let urlToImage = newsForToday[indexPath.row].urlToImage, let url = URL(string: urlToImage) {
            cell.newsImage.kf.setImage(with: url)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !didLoadAllNews {
            newsView.startActivityIndicator()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: newsForToday[indexPath.row].url) else { return () }

        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
}

extension NewsViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDataLoading = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if ((newsView.tableView.contentOffset.y + newsView.tableView.frame.size.height) >= newsView.tableView.contentSize.height), !isDataLoading {
            isDataLoading = true
            pageNumber = pageNumber + 1
            
            newsManager.fetchNews(pageNumber: pageNumber, pageSize: pageSize, completion: handleNewsResult)
        }
    }
}
