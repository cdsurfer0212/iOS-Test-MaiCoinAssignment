//
//  FavoriteViewModel.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/26.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import Foundation

class FavoriteViewModel {
    private var data: [Cryptocurrency] = [Cryptocurrency]()
    
    private var homeCellViewModels: [HomeCellViewModel] = [HomeCellViewModel]() {
        didSet {
            self.reloadCollectionViewBlock?()
        }
    }
    
    var numberOfCells: Int {
        return homeCellViewModels.count
    }
    
    var reloadCollectionViewBlock: (() -> ())?
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        if let data = FavoriteCoreData.getAllCryptocurrency() {
            self.data = data
            homeCellViewModels.removeAll()
            for d in data {
                homeCellViewModels.append(HomeCellViewModel(cryptocurrency: d))
            }
            self.reloadCollectionViewBlock?()
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> HomeCellViewModel {
        return homeCellViewModels[indexPath.item]
    }
    
    func removeData(at indexPath: IndexPath) {
        if indexPath.item < data.count {
            data.remove(at: indexPath.item)
            homeCellViewModels.remove(at: indexPath.item)
        }
    }
    
}
