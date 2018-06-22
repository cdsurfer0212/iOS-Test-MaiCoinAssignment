//
//  Cryptocurrency.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/24.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import Foundation

class Cryptocurrency: NSObject, Decodable, NSCoding {
    var id: Int?
    var name: String?
    var quotes: Quotes?
    var rank: Int?
    var symbol: String?
    var websiteSlug: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, quotes, rank, symbol, websiteSlug = "website_slug"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(quotes, forKey: "quotes")
        aCoder.encode(rank, forKey: "rank")
        aCoder.encode(symbol, forKey: "symbol")
        aCoder.encode(websiteSlug, forKey: "websiteSlug")
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? Int
        name = aDecoder.decodeObject(forKey: "name") as? String
        quotes = aDecoder.decodeObject(forKey: "quotes") as? Quotes
        rank = aDecoder.decodeObject(forKey: "rank") as? Int
        symbol = aDecoder.decodeObject(forKey: "symbol") as? String
        websiteSlug = aDecoder.decodeObject(forKey: "websiteSlug") as? String
    }
}
