//
//  CoinMarketCapAPI.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/23.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import Foundation
import Moya

enum CoinMarketCapAPI {
    case getTicker(sort: String, start: Int, limit: Int)
}

extension CoinMarketCapAPI: TargetType {
    var baseURL: URL { return URL(string: "https://api.coinmarketcap.com")! }
    var path: String {
        switch self {
        case .getTicker(_, _, _):
            return "/v2/ticker/"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getTicker:
            return .get
        }
    }
    var task: Task {
        switch self {
        case let .getTicker(sort, start, limit):
            return .requestParameters(parameters: ["sort": sort, "structure": "array", "start": start, "limit": limit], encoding: URLEncoding.queryString)
        }
    }
    var sampleData: Data {
        switch self {
        case .getTicker(_, _, _):
            guard let url = Bundle.main.url(forResource: "ticker", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

