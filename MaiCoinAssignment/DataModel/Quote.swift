//
//  Quote.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/24.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import Foundation

class Quote: NSObject, Decodable, NSCoding {
    var marketCap: Double?
    var percentChange24h: Double?
    var price: Double?
    var volume24h: Double?
    
    private enum CodingKeys: String, CodingKey {
        case marketCap = "market_cap", percentChange24h = "percent_change_24h", price, volume24h = "volume24h"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(marketCap, forKey: "marketCap")
        aCoder.encode(percentChange24h, forKey: "percentChange24h")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(volume24h, forKey: "volume24h")
    }
    
    required init?(coder aDecoder: NSCoder) {
        marketCap = aDecoder.decodeObject(forKey: "marketCap") as? Double
        percentChange24h = aDecoder.decodeObject(forKey: "percentChange24h") as? Double
        price = aDecoder.decodeObject(forKey: "price") as? Double
        volume24h = aDecoder.decodeObject(forKey: "volume24h") as? Double
    }
}
