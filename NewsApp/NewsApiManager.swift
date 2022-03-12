//
//  NewsApiManager.swift
//  NewsApp
//
//  Created by Мария Газизова on 11.03.2022.
//

import Foundation
import SwiftUI

enum PosibleErrors: Error {
    case decodingError
    case restError
    case otherError
}

extension PosibleErrors: LocalizedError {
    public var localizedDescription: String? {
        switch self {
        case .decodingError:
            return "Sorry. Format of news is unknown"
        case .restError:
            return "Service is temporarily unavailable. Try later"
        case .otherError:
            return "Something went wrong. Try again"
        }
    }
}

class NewsApiManager {
            
    typealias Handler = (Result<NewsGroup, Error>) -> Void

    func fetchNews(completion: @escaping Handler) {
        
        var request = URLRequest(url: NewsEndPoint.appleNewsForToday.fullUrl())
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let error = error { completion(.failure(error)) }
            
            do {
                if let data = data {
                    let currentNews: NewsGroup = try JSONDecoder().decode(NewsGroup.self, from: data)
                    completion(.success(currentNews))
                }
            }
            catch let error as NSError{
                switch error.code {
                case 4865:
                    completion(.failure(PosibleErrors.decodingError))
                case 4864:
                    completion(.failure(PosibleErrors.restError))
                default:
                    completion(.failure(PosibleErrors.otherError))
                }
            }
        }).resume()
    }
}
