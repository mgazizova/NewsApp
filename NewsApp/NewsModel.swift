//
//  NewsModel.swift
//  NewsApp
//
//  Created by Мария Газизова on 02.03.2022.
//

import Foundation

struct NewsModel {
    let title: String
}

struct NewsGroup {
    let news: [NewsModel]
    
    static func emptyNews() -> NewsGroup {
        return NewsGroup(news: [])
    }
    
    static func updateNews(completion: ((NewsGroup) -> (Void))?) {
        let apiKey = "687e62c563ac4342959cf12264aabeed"
        guard let URL = URL(string: "https://newsapi.org/v2/everything?q=tesla&from=2022-02-02&sortBy=publishedAt&apiKey=\(apiKey)") else {
            completion?(emptyNews())
            return ()
        }
         
        getNews(url: URL) { result in
            completion?(NewsGroup(news: result))
        }
    }

    private static func getNews(url: URL, completion: (([NewsModel]) -> (Void))?) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
    
        let session = URLSession.shared
        session.dataTask(
            with: request,
            completionHandler: { data, response, error -> Void in
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as! Dictionary<String, Any>
                    var currentNews: [NewsModel] = []
                    
                    if let articles = json["articles"] as? Array<Dictionary<String, Any>> {
                        for i in 0..<articles.count {
                            currentNews.append(NewsModel(title: (articles[i]["title"] as! String)))
                        }
                    }
                    print(currentNews)
                    completion?(currentNews)
                } catch {
                    print("ERROR")
                }
            }).resume()
    }
}

