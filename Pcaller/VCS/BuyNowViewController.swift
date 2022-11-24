//
//  StoreKitViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 20/11/2022.
//

import UIKit
import StoreKit
import KeychainSwift

class BuyNowViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate{

    @IBOutlet weak var buyStackView: UIStackView!
    @IBOutlet weak var imageApp: UIImageView!
    @IBOutlet weak var buyNowButton: UIButton!
    @IBOutlet weak var buyNowLabel: UILabel!

    var service = Service.shared
    let productID = "com.Pcaller.buyUnlimitedCalls"

    var myProduct: SKProduct? {
        didSet {
            if let receivedProduct = myProduct {
                DispatchQueue.main.async { [weak self] in
                    self?.buyNowLabel.text = """
Enjoy making unlimited  anonymous calls
No subscription fees
And only at a price of \(receivedProduct.localizedPrice)
without monthly subscription  fees, a one-time payment! 
Buy now
"""
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchProducts()
        SKPaymentQueue.default().add(self)
    }

    @IBAction func buyNowButton(_ sender: Any) {
        if SKPaymentQueue.canMakePayments() {
            buyNowButton.setTitle("Loading Please wait...", for: .normal)
            buyNowButton.backgroundColor = UIColor.clear
            buyNowButton.isEnabled = false
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("## User unable to make payments")
        }
    }

    func setupView(){
        imageApp.layer.cornerRadius = 20
        imageApp.layer.masksToBounds = true
        buyStackView.layer.cornerRadius = 20
    }

    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        myProduct = response.products.first //Only one product
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                let keychain = KeychainSwift()
                print("## Purchased")
                keychain.set(true, forKey: "userBuy")
                service.showAlert(vc: self, title: "Thank you for purchase", message: "To update the app you need to exit and run again", textTitleOk: "EXIT", cancelButton: false, style: .destructive) {
                    exit(0)
                }
            } else if transaction.transactionState == .failed {
                buyNowButton.setTitle("Buy Now!", for: .normal)
                buyNowButton.isEnabled = true
                print("## Transaction Failed")
            }
        }
    }
}
extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
