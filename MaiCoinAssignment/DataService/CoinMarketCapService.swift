//
//  CoinMarketCapService.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/24.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import Foundation
import Moya

class CoinMarketCapService {
    static let provider = MoyaProvider<CoinMarketCapAPI>()
    
    static func getTicker(sort: String, start: Int, limit: Int, completion: @escaping ([Cryptocurrency]) -> ()) {
        provider.request(.getTicker(sort: sort, start: start, limit: limit)) { result in
            switch result {
            case let .success(response):
                do {
                    try response.filterSuccessfulStatusCodes()
                    let cryptocurrencys = try response.map([Cryptocurrency].self, atKeyPath: "data", using: JSONDecoder(), failsOnEmptyData: false)
                    completion(cryptocurrencys)
                } catch let error {
                    // FIXME
                    print(error)
                }
                break
            case let .failure(error):
                // FIXME
                print(error)
                break
            }
        }
    }
}
