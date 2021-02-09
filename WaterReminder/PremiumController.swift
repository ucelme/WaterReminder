import UIKit
import SwiftyStoreKit

class PremiumController: UIViewController {

    @IBOutlet weak var buyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SwiftyStoreKit.retrieveProductsInfo(["\(AppInfo.oneTimePurchase)"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
                self.buyButton.setTitle("\(priceString) one time", for: .normal)
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
            }
        }
                
        buyButton.layer.cornerRadius = buyButton.frame.height/2
        buyButton.layer.masksToBounds = true
    }
    
    @IBAction func buyButtonPressed(_ sender: UIButton) {
        SwiftyStoreKit.purchaseProduct("\(AppInfo.oneTimePurchase)", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: "Premium")
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }

    }
    
    @IBAction func restorePurchasesButtonPressed(_ sender: UIButton) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                UserDefaults.standard.set(true, forKey: "Premium")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
}
