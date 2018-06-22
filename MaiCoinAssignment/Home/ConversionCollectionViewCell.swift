//
//  ConversionCollectionViewCell.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/26.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import UIKit

let conversionCollectionViewCellIdentifier = "ConversionCollectionViewCell"

class ConversionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cryptocurrencySymbolLabel: UILabel!
    @IBOutlet weak var fiatCurrencySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cryptocurrencySymbolLabel.text = ""
        fiatCurrencySymbolLabel.text = ""
        priceLabel.text = ""
    }

}
