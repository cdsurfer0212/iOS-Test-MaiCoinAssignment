//
//  FavoriteViewController.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/23.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

//import RxSwift
import SwipeCellKit
import UIKit

class FavoriteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    //private let disposeBag = DisposeBag()
    //private var data: [Cryptocurrency] = [Cryptocurrency]()
    //private var dataVariable = Variable<[Cryptocurrency]>([])
    private var viewModel: FavoriteViewModel = FavoriteViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorite"
        
//        dataVariable.asObservable().bind(to: collectionView.rx.items(cellIdentifier: homeCollectionViewCellIdentifier, cellType: HomeCollectionViewCell.self)) { item, cryptocurrency, cell in
//            cell.cryptocurrency = cryptocurrency
//            cell.delegate = self
//            }.disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receceiveFavoriteSavedNotification(notification:)), name: Notification.Name("FavoriteSavedNotification"), object: nil)
        
        // MVVM
        viewModel.reloadCollectionViewBlock = { [weak self] () in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        setupCollectionView()
        viewModel.fetchData()
    }
    
    // MARK: Notification
    
    @objc func receceiveFavoriteSavedNotification(notification: Notification) {
        viewModel.fetchData()
    }
    
    // MARK: Private methods
    
//    func fetchData() {
//        if let data = FavoriteCoreData.getAllCryptocurrency() {
//            self.data = data
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        }
//    }
    
    func setupCell() {
        collectionView.register(UINib(nibName: homeCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: homeCollectionViewCellIdentifier)
    }
    
    func setupCollectionView() {
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        
        setupCell()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeCollectionViewCellIdentifier, for: indexPath) as! HomeCollectionViewCell
        //let cryptocurrency = data[indexPath.item]
        // MVVM
        let viewModel = self.viewModel.getCellViewModel(at: indexPath)
        let cryptocurrency = viewModel.cryptocurrency
        cell.cryptocurrency = cryptocurrency
        cell.delegate = self
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cryptocurrencyViewController = CryptocurrencyViewController.init(cryptocurrency: viewModel.getCellViewModel(at: indexPath).cryptocurrency as Cryptocurrency)
        navigationController?.pushViewController(cryptocurrencyViewController, animated: true)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ADKNibSizeCalculator.sharedInstance().size(forNibNamed: homeCollectionViewCellIdentifier, with: ADKNibSizeStyle.fixedHeightScaling)
    }
    
}

extension FavoriteViewController: SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return nil
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            if let strongSelf = self {
                let cryptocurrency = strongSelf.viewModel.getCellViewModel(at: indexPath).cryptocurrency
                if let id = cryptocurrency.id {
                    FavoriteCoreData.delete(cryptocurrencyId: id)
                    strongSelf.viewModel.removeData(at: indexPath)
                }
            }
        }
        deleteAction.image = UIImage(named: "Icon-TrashCan")

        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}
