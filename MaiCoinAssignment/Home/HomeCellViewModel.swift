//
//  HomeCellViewModel.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/26.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import Foundation

struct HomeCellViewModel {
    let cryptocurrency: Cryptocurrency
    init(cryptocurrency: Cryptocurrency) {
        self.cryptocurrency = cryptocurrency
    }
}
