//
//  HomeCollectionViewCell.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/23.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import SDWebImage
import SwipeCellKit
import UIKit

let homeCollectionViewCellIdentifier = "HomeCollectionViewCell"

class HomeCollectionViewCell: SwipeCollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var percentLabel: StyleLabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    var cryptocurrency: Cryptocurrency? {
        didSet {
            guard let cryptocurrency = cryptocurrency else {
                return
            }
            
            if let websiteSlug = cryptocurrency.websiteSlug {
                imageView.sd_setImage(with: URL(string: "https://files.coinmarketcap.com/static/widget/coins_legacy/64x64/\(websiteSlug).png"), placeholderImage: UIImage(named: "Icon-Placeholder"))
            }
            nameLabel.text = cryptocurrency.name
            
            if let percent = cryptocurrency.quotes?.USD?.percentChange24h {
                percentLabel.backgroundColor = percent > 0 ? UIColor.green : UIColor.red
                percentLabel.isHidden = false
                percentLabel.text = "\(cryptocurrency.quotes?.USD?.percentChange24h.map { String($0) } ?? "")%"
            } else {
                percentLabel.isHidden = true
            }
            
            if let price = cryptocurrency.quotes?.USD?.price {
                let currencyFormatter = NumberFormatter()
                currencyFormatter.locale = Locale.current
                currencyFormatter.numberStyle = .currency
                currencyFormatter.usesGroupingSeparator = true
                let priceString = currencyFormatter.string(from: price as NSNumber)!
                priceLabel.text = priceString
            }
            
            rankLabel.text = "#\(cryptocurrency.rank.map { String($0) } ?? "")"
            symbolLabel.text = cryptocurrency.symbol
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        percentLabel.layer.cornerRadius = 4.0
        percentLabel.layer.masksToBounds = true
        percentLabel.edgeInsets = UIEdgeInsets.init(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        percentLabel.textColor = UIColor.white
    }
    
}
