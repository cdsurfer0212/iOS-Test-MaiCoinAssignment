//
//  ViewController.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/22.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import CoreData
import RxCocoa
import RxSwift
import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    private let disposeBag = DisposeBag()
    private var data: [Cryptocurrency] = [Cryptocurrency]()
    private var dataVariable = Variable<[Cryptocurrency]>([])

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Home"
        searchBar.barTintColor = UIColor.white
        searchBar.delegate = self
        
        dataVariable.asObservable().bind(to: collectionView.rx.items(cellIdentifier: homeCollectionViewCellIdentifier, cellType: HomeCollectionViewCell.self)) { item, cryptocurrency, cell in
            cell.cryptocurrency = cryptocurrency
        }.disposed(by: disposeBag)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        setupInfiniteScrollingView()
        setupCollectionView()
        
        if let data = CryptocurrencyCoreData.getAll() {
            dataVariable.value = data
        }
        
        fetchData(start: 1, limit: 10)
    }

    // MARK: Private methods
    
    func fetchData(start: Int, limit: Int) {
        CoinMarketCapService.getTicker(sort: "rank", start: start, limit: limit) { [weak self] (cryptocurrencys) in
            if let strongSelf = self {
                if start == 1 && cryptocurrencys.count > 0 {
                    strongSelf.data .removeAll()
                }
                
                strongSelf.data.append(contentsOf: cryptocurrencys)
                strongSelf.dataVariable.value = strongSelf.data
                
                // save into local storage
                CryptocurrencyCoreData.insert(cryptocurrencys: strongSelf.data)
                
                //strongSelf.collectionView.reloadData()
                strongSelf.collectionView.infiniteScrollingContentView.stopAnimating()
            }
        }
    }
    
    @objc func filterData(keyword: String) {
        dataVariable.value = data.filter({($0.symbol?.lowercased().contains(keyword.lowercased())) ?? false})
    }
    
    func setupCell() {
        collectionView.register(UINib(nibName: homeCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: homeCollectionViewCellIdentifier)
    }
    
    func setupCollectionView() {
        //collectionView.dataSource = self
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        
        setupCell()
    }
    
    func setupInfiniteScrollingView() {
        let activityIndicatorView = InfiniteScrollingView.init(frame: CGRect(x: 0.0, y: 0.0, width: collectionView.frame.width, height: 50.0))
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicatorView.hidesWhenStopped = false
        activityIndicatorView.startAnimating()
        
        collectionView.adkAddInfiniteScrolling(withHandle: activityIndicatorView) { [weak self] in
            if let strongSelf = self {
                strongSelf.fetchData(start: strongSelf.data.count, limit: 10)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return data.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeCollectionViewCellIdentifier, for: indexPath) as! HomeCollectionViewCell
//        let cryptocurrency = data[indexPath.item]
//        cell.cryptocurrency = cryptocurrency
//        return cell
//    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cryptocurrencyViewController = CryptocurrencyViewController.init(cryptocurrency: data[indexPath.item] as Cryptocurrency)
        navigationController?.pushViewController(cryptocurrencyViewController, animated: true)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ADKNibSizeCalculator.sharedInstance().size(forNibNamed: homeCollectionViewCellIdentifier, with: ADKNibSizeStyle.fixedHeightScaling)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            filterData(keyword: searchText)
        } else {
            dataVariable.value = data
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
}
