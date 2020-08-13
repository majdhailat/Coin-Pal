import UIKit
/*
 View controller for the bought/sold screen
 adds or subtracts amount (specified by user in the text field) to the coins balance
 Refreshed the parent VC when dismissed
 */
class AddToBalanceViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!//text field to enter amount to add/subtract
    @IBOutlet weak var howMuchLabel: UILabel!
    
    var coinHandler: CoinHandler?
    var isSell: Bool?//if the user clicked on the sell button not the bought
    var coinID: String?
    
    override func viewDidLoad() {
        let buyOrSellLabel: String?
        
        //setting label text depending on buy/sell and coin name
        switch isSell {
        case true:
            buyOrSellLabel = "sell"
        default:
            buyOrSellLabel = "buy"
        }
        howMuchLabel.text = "How much \(Coin.coinTickers[coinID ?? ""] ?? "") did you \(buyOrSellLabel!)?"
        textField.delegate = self
        super.viewDidLoad()
    }
}

//MARK: - UITextField Delegate
extension AddToBalanceViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismiss(animated: true, completion: nil)//dismissing vc
        if let amountToAdd = Double(textField.text!){//checking if amount to add is a double
            if (isSell!){//checking for sell
                coinHandler?.addToManualBalance(of: coinID!, amount: (amountToAdd * -1))//adding the negative
            }else{//buy
                coinHandler?.addToManualBalance(of: coinID!, amount: amountToAdd)
            }
        }
        ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
        if let firstVC = presentingViewController as? PortfolioViewController {
            DispatchQueue.main.async {
                firstVC.viewDidLoad()//refreshing parent VC
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

//MARK: - ModalTransitionListener
protocol ModalTransitionListener {
    func popoverDismissed()
}

class ModalTransitionMediator {
    /* Singleton */
    class var instance: ModalTransitionMediator {
        struct Static {
            static let instance: ModalTransitionMediator = ModalTransitionMediator()
        }
        return Static.instance
    }
    
    private var listener: ModalTransitionListener?

    private init() {}

    func setListener(listener: ModalTransitionListener) {
        self.listener = listener
    }

    func sendPopoverDismissed(modelChanged: Bool) {
        listener?.popoverDismissed()
    }
}
