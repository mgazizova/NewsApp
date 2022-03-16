//
//  NewsApiManager.swift
//  NewsApp
//
//  Created by Мария Газизова on 11.03.2022.
//

import Foundation

enum CustomError: Error {
    case decoding
    case restAPI
    case lostConnection
    case unknown
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .decoding:
            return "Sorry. Format of news is unknown"
        case .restAPI:
            return "Service is temporarily unavailable. Try later"
        case .lostConnection:
            return "Internet connection is lost. Please check your connection"
        case .unknown:
            return "Something went wrong. Try again"
        }
    }
}

class NewsApiManager {
            
    typealias Handler = (Result<NewsGroup, CustomError>) -> Void

    func fetchNews(pageNumber: Int?, pageSize: Int?, completion: @escaping Handler) {
        guard let pageNumber = pageNumber,
              let pageSize = pageSize,
              let url = NewsEndPoint.appleNewsForToday(page: pageNumber, pageSize: pageSize).fullUrl else {
                  completion(.failure(CustomError.unknown))
                  return
              }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if let error = error { throw error }
                
                if let data = data {
                    let currentNews: NewsGroup = try JSONDecoder().decode(NewsGroup.self, from: data)
                    
                    guard currentNews.status != "error" else {
                        completion(.failure(CustomError.unknown))
                        return
                    }

                    completion(.success(currentNews))
                }
            }
            catch let error as NSError {
                switch error.code {
                case 4865:
                    completion(.failure(CustomError.decoding))
                case 4864:
                    completion(.failure(CustomError.restAPI))
                case -1009:
                    completion(.failure(CustomError.lostConnection))
                default:
                    completion(.failure(CustomError.unknown))
                }
            }
        }).resume()
    }
}
