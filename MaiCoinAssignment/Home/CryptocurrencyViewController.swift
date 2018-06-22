//
//  CryptocurrencyViewController.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/25.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import Alamofire
import CoreData
import SwiftyJSON
import UIKit

class CryptocurrencyViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var textField : UITextField!
    
    private let fiatCryptocurrencySymbols = ["AUD", "BRL", "CAD", "CHF", "CLP", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PKR", "PLN", "RUB", "SEK", "SGD", "THB", "TRY", "TWD", "ZAR"]
    private var cryptocurrency: Cryptocurrency?
    private var data: [String] = [String]()
    private var dataDictionary: [String:Double] = [String:Double]()
    private var favoriteBarButtonItem: UIBarButtonItem?
    private var priceOfCurrentFiatCurrency: Double?
    
    init(cryptocurrency: Cryptocurrency?) {
        if let cryptocurrency = cryptocurrency {
            self.cryptocurrency = cryptocurrency
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = cryptocurrency?.name
        //let favoriteBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(tapFavoriteButton))
        //navigationItem.rightBarButtonItems = [favoriteBarButtonItem]
        favoriteBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "Icon-Favorite"), style: .done, target: self, action: #selector(tapFavoriteButton))
        favoriteBarButtonItem?.tintColor = FavoriteCoreData.isFavorite(cryptocurrencyId: (cryptocurrency?.id)!) ? UIColor.adkColor(withHexRed: 0, green: 122, blue: 255, alpha: 1.0) : UIColor.lightGray
        navigationItem.rightBarButtonItem = favoriteBarButtonItem
        
        priceLabel.text = String(cryptocurrency?.quotes?.USD?.price ?? 0)
        symbolLabel.text = cryptocurrency?.symbol
       
        textField.delegate = self
        let pickerView = UIPickerView()
        pickerView.delegate = self
        textField.inputView = pickerView
        textField.text = "USD"
        textField.textAlignment = .center
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receceiveFavoriteSavedNotification(notification:)), name: Notification.Name("FavoriteSavedNotification"), object: nil)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        setupCollectionView()
        fetchData()
    }
    
    // MARK: Notification
    
    @objc func receceiveFavoriteSavedNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Private methods
    
    func fetchData() {
        guard let cryptocurrencyId = cryptocurrency?.id else {
            return
        }
        guard let fiatCurrencySymbols = FavoriteCoreData.getFiatCurrencySymbolsBy(cryptocurrencyId: cryptocurrencyId) else {
            return
        }
        data = fiatCurrencySymbols
        for (index, fiatCurrencySymbol) in fiatCurrencySymbols.enumerated() {
            dataDictionary[fiatCurrencySymbol] = 0.0
            fetchData(fiatCurrencySymbol: fiatCurrencySymbol) { [weak self, fiatCurrencySymbol] (response) in
                guard let value = response.result.value else {
                    return
                }
                if let strongSelf = self {
                    let json = JSON(value)
                    strongSelf.dataDictionary[fiatCurrencySymbol] = json["data"]["quotes"][fiatCurrencySymbol]["price"].doubleValue
                    strongSelf.collectionView.reloadItems(at: [NSIndexPath.init(item: index, section: 0) as IndexPath])
                }
            }
        }
    }
    
    func fetchData(fiatCurrencySymbol: String, completion: @escaping (DataResponse<Any>) -> Void) {
        guard let cryptocurrencyId = cryptocurrency?.id else {
            return
        }
        Alamofire.request("https://api.coinmarketcap.com/v2/ticker/\(cryptocurrencyId)/", method: .get, parameters: ["convert": fiatCurrencySymbol], encoding: URLEncoding.default).validate { request, response, data in
            return .success
            }.responseJSON { response in
                completion(response)
        }
    }
    
    func setupCell() {
        collectionView.register(UINib(nibName: conversionCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: conversionCollectionViewCellIdentifier)
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
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversionCollectionViewCellIdentifier, for: indexPath) as! ConversionCollectionViewCell
        cell.cryptocurrencySymbolLabel.text = cryptocurrency?.symbol
        cell.fiatCurrencySymbolLabel.text = data[indexPath.item]
        if let price = dataDictionary[data[indexPath.item]], price > 0 {
            cell.priceLabel.text = String(price)
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ADKNibSizeCalculator.sharedInstance().size(forNibNamed: conversionCollectionViewCellIdentifier, with: ADKNibSizeStyle.fixedHeightScaling)
    }
    
    // MARK: UI events
    
    @IBAction func tapAddButton(_ sender: Any) {
        if let cryptocurrencyId = cryptocurrency?.id, let fiatCurrencySymbol = textField.text {
            guard !data.contains(fiatCurrencySymbol) else {
                return
            }
            FavoriteCoreData.insert(cryptocurrencyId: cryptocurrencyId, fiatCurrencySymbol: fiatCurrencySymbol)
            data.append(fiatCurrencySymbol)
            if let priceOfCurrentFiatCurrency = priceOfCurrentFiatCurrency {
                dataDictionary[fiatCurrencySymbol] = priceOfCurrentFiatCurrency
            }
            collectionView.reloadData()
            favoriteBarButtonItem?.tintColor = UIColor.adkColor(withHexRed: 0, green: 122, blue: 255, alpha: 1.0)
        }
        textField.resignFirstResponder()
    }
    
    @IBAction func tapFavoriteButton(_ sender: Any) {
        if FavoriteCoreData.isFavorite(cryptocurrencyId: (cryptocurrency?.id)!) {
            if let cryptocurrencyId = cryptocurrency?.id {
                FavoriteCoreData.delete(cryptocurrencyId: cryptocurrencyId)
                favoriteBarButtonItem?.tintColor = UIColor.lightGray
            }
        } else {
            if let cryptocurrencyId = cryptocurrency?.id, let fiatCurrencySymbol = textField.text {
                FavoriteCoreData.insert(cryptocurrencyId: cryptocurrencyId, fiatCurrencySymbol: fiatCurrencySymbol)
                favoriteBarButtonItem?.tintColor = UIColor.adkColor(withHexRed: 0, green: 122, blue: 255, alpha: 1.0)
            }
        }
        textField.resignFirstResponder()
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fiatCryptocurrencySymbols.count
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fiatCryptocurrencySymbols[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let fiatCurrencySymbol = fiatCryptocurrencySymbols[row]
        textField.text = fiatCurrencySymbol
        fetchData(fiatCurrencySymbol: fiatCryptocurrencySymbols[row]) { [weak self, fiatCurrencySymbol] (response) in
            guard let value = response.result.value else {
                return
            }
            if let strongSelf = self {
                let json = JSON(value)
                strongSelf.priceOfCurrentFiatCurrency = json["data"]["quotes"][fiatCurrencySymbol]["price"].doubleValue
                let price = json["data"]["quotes"][fiatCurrencySymbol]["price"].stringValue
                let index = price.index(of: ".")
                if let encodedOffset = index?.encodedOffset {
                    strongSelf.priceLabel.text = String(price.prefix(encodedOffset + 4))
                } else {
                    strongSelf.priceLabel.text = price
                }
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }

}
