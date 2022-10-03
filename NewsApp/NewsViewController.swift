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

    @IBOutlet weak var tableLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private var activityIndicator = UIActivityIndicatorView()

    // for pagination
    private var isDataLoading = false
    private var pageNumber = 1
    private let pageSize = 10
    private var totalResult: Int?
    private var didLoadAllNews = false

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        newsManager.fetchNews(pageNumber: pageNumber, pageSize: pageSize) { [weak self] result in
            self?.handleNewsResult(result: result)
        }
    }

    private func configure() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = 300
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        tableView.separatorStyle = .none

        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.frame = CGRect(x: CGFloat(0),
                                         y: CGFloat(20),
                                         width: tableView.bounds.width,
                                         height: CGFloat(44))
        activityIndicator.hidesWhenStopped = true
        startActivityIndicator()
    }

    func startActivityIndicator() {
        tableView.tableFooterView = activityIndicator
        activityIndicator.startAnimating()
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        tableView.tableFooterView = nil
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
                self.tableView.reloadData()
                self.stopActivityIndicator()
            }
        case .failure(let error):
            showAlert(error: error)
        }
    }

    private func showAlert(error: CustomError) {
        let alert = UIAlertController(title: "Error", message: error.errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        alert.addAction(UIAlertAction(title: "Try again", style: .default) {(_) -> Void in
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as? NewsTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(withText: newsForToday[indexPath.row].title, byAuthor: newsForToday[indexPath.row].author ?? "")

        if let urlToImage = newsForToday[indexPath.row].urlToImage, let url = URL(string: urlToImage) {
            cell.newsImage.kf.setImage(with: url)
        }
        return cell
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y + tableView.frame.size.height + 100 >=
            tableView.contentSize.height,
            !isDataLoading,
            !didLoadAllNews {
            startActivityIndicator()
            isDataLoading = true
            pageNumber += 1

            newsManager.fetchNews(pageNumber: pageNumber, pageSize: pageSize, completion: handleNewsResult)
        }
    }
}
