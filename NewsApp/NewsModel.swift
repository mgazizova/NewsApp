//
//  NewsModel.swift
//  NewsApp
//
//  Created by Мария Газизова on 02.03.2022.
//

import Foundation

struct NewsModel: Decodable {
    let title: String
    let url: String
    let urlToImage: String?
    let author: String?
}

struct NewsGroup: Decodable {
    let articles: [NewsModel]
}
