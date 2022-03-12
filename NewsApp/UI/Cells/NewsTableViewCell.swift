//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Мария Газизова on 10.03.2022.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var author: UILabel!

    func configure(withText: String, byAuthor: String) {
        title.text = withText
        title.textColor = .white
        title.backgroundColor = .clear
        title.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 25)
       
        author.text = byAuthor
        author.textColor = .white
        author.backgroundColor = .clear
        author.font = UIFont(name: "AppleSDGothicNeo-Light", size: 20)
        author.textAlignment = .right
        
        newsImage.alpha = 0.5
        
        contentView.bringSubviewToFront(title)
        contentView.bringSubviewToFront(author)
        contentView.layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
}
