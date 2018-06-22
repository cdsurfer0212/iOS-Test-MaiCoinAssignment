//
//  Quotes.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/24.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import Foundation

class Quotes: NSObject, Decodable, NSCoding {
    var USD: Quote?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(USD, forKey: "USD")
    }
    
    required init?(coder aDecoder: NSCoder) {
        USD = aDecoder.decodeObject(forKey: "USD") as? Quote
    }
}
