import UIKit
/*
 View controller for the portfolio screen
    - Handles the initial placeholder text of the text fields
    - Handles the look of the buttons
    - Adopts the UITextFieldDelegate which manges portfolio changes
 */
class PortfolioViewController: UIViewController, ModalTransitionListener {
    @IBOutlet weak var autoBalanceStack: UIStackView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var manualBalanceTextField: UITextField!
    @IBOutlet weak var address1TextField: UITextField!
    @IBOutlet weak var address2TextField: UITextField!
    @IBOutlet weak var boughtButton: UIButton!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var addressDisclaimerText: UILabel!
    
    private let defaults = UserDefaults.standard
    var coinHandler: CoinHandler?
    var coinID: String?
    private var coinName: String?
    private var coinTicker: String?
    
    override func viewDidLoad() {
        ModalTransitionMediator.instance.setListener(listener: self)
        coinName = Coin.coinNames[coinID ?? ""] ?? ""
        coinTicker =  Coin.coinTickers[coinID ?? ""] ?? ""
        iconImage.image = UIImage(named: coinID!)//setting the coin icon
        
        //setting the properties for the bought and sold buttons
        for i in 1...2{
            let button: UIButton!
            if i == 1{
                button = boughtButton
            }else{
                button = soldButton
            }
            button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            button.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            button.layer.shadowOpacity = 1.0
            button.layer.shadowRadius = 0.0
            button.layer.cornerRadius = 10
        }
        
        manualBalanceTextField.delegate = self
        address1TextField.delegate = self
        address2TextField.delegate = self
        initPlaceHolderText()
        super.viewDidLoad()
    }
    
    /*
     Called when the AddToBalance view is dismissed
     */
    func popoverDismissed() {
        initPlaceHolderText()
    }
    
    /*
     Initializes the placeholder text for the balance
     */
    func initPlaceHolderText(){
        let userCoins:[String: Double] = defaults.dictionary(forKey: "coins")! as! [String : Double]
        //manual balance text fields
        if (userCoins[coinID!]! == 0){
            manualBalanceTextField.placeholder = "Enter your balance"
        }else{
            manualBalanceTextField.placeholder = String(userCoins[coinID!]!)
        }
        //automatic balance text fields
        if (Coin.coinsWithAutomaticAddressRefresh.contains(coinID!)){//checking if the automatic text field should be shown
            if (defaults.string(forKey: "\(Coin.coinTickers[coinID!]!)address1") != nil){
                address1TextField.placeholder = defaults.string(forKey: "\(Coin.coinTickers[coinID!]!)address1")!//displaying the addresses as the place holder text
            }
            if (defaults.string(forKey: "\(Coin.coinTickers[coinID!]!)address2") != nil){
                address2TextField.placeholder = defaults.string(forKey: "\(Coin.coinTickers[coinID!]!)address2")!
            }
        }else{
            autoBalanceStack.isHidden = true
        }
        
        if (coinID != "bitcoin"){//checking if coin is not bitcoin
            addressDisclaimerText.isHidden = true//hiding disclaimer text
        }
    }

    /*
    Called whenever a new view controller is about to come up
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if (segue.identifier == "goToAddToBalance"){
            if let sender : UIButton = sender as? UIButton{
                let destinationVC = segue.destination as! AddToBalanceViewController
                destinationVC.coinID = coinID
                destinationVC.coinHandler = coinHandler
                if sender == soldButton{
                    destinationVC.isSell = true
                }else{
                    destinationVC.isSell = false
                }
            }
         }
    }
}
