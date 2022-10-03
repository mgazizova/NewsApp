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
    var fullUrl: URL? { get }
}

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}

extension UrlComponents {
    var fullUrl: URL? {
        guard let url = URL(string: baseUrl) else { return nil }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.path = path
        components?.setQueryItems(with: params)

        return components?.url
    }
}

enum NewsEndPoint {
    case teslaNewsForToday(page: Int, pageSize: Int)
    case appleNewsForToday(page: Int, pageSize: Int)
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
        switch self {
        case let .teslaNewsForToday(page, pageSize):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return [
                "q": "tesla",
                "apiKey": "687e62c563ac4342959cf12264aabeed",
                "sortBy": "publishedAt",
                "from": formatter.string(from: Date()),
                "page": "\(page)",
                "pageSize": "\(pageSize)",
                "language": "en"
            ]
        case let .appleNewsForToday(page, pageSize):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return [
                "q": "apple",
                "apiKey": "687e62c563ac4342959cf12264aabeed",
                "sortBy": "popularity",
                "from": formatter.string(from: Date()),
                "page": "\(page)",
                "pageSize": "\(pageSize)",
                "language": "en"
            ]
        }
    }
}
