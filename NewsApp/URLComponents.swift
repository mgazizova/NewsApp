//
//  URLComponents.swift
//  NewsApp
//
//  Created by Мария Газизова on 12.03.2022.
//

import Foundation
import WebKit

protocol UrlComponents {
    var baseUrl: String { get }
    var path: String { get }
    var params: [String: String] { get }
    //TODO Убрать отсюда, формировать урл в менеджере
    func fullUrl() -> URL
}
//TODO Тоже не понадобится
extension UrlComponents {
    func fullUrl() -> URL {
        let queryParams = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        
        return URL(string: "\(baseUrl)\(path)?\(queryParams)")!
    }
}

enum NewsEndPoint {
    case teslaNewsForToday
    case appleNewsForToday
}

extension NewsEndPoint: UrlComponents {
    var baseUrl: String {
        switch self {
        case .teslaNewsForToday, .appleNewsForToday:
            return "https://newsapi.org"
        }
    }
    
    var path: String {
        switch self {
        case .teslaNewsForToday, .appleNewsForToday:
            return "/v2/everything"
        }
    }
    
    var params: [String: String] {
        get {
            switch self {
            case .teslaNewsForToday:
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return [
                    "q": "tesla",
                    "apiKey": "687e62c563ac4342959cf12264aabeed",
                    "sortBy": "publishedAt",
                    "from": formatter.string(from: Date())
                ]
            case .appleNewsForToday:
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return [
                    "q": "apple",
                    "apiKey": "687e62c563ac4342959cf12264aabeed",
                    "sortBy": "popularity",
                    "from": formatter.string(from: Date())
                ]
            }
        }
    }
}
