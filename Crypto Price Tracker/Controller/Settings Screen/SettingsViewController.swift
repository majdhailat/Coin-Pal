import UIKit
import StoreKit
/*
 View controller for the settings screen
 Sets the support button attributes
 Manges the fiat picker and the sort type picker
    - Sets the default values for both
    - Sets the new sort type/ fiat when the user makes a new selection 
 */
class SettingsViewController: UIViewController {
    @IBOutlet weak var fiatPicker: UIPickerView!
    @IBOutlet weak var sortTypePicker: UIPickerView!
    @IBOutlet weak var supportButton: UIButton!
    
    var coinHandler: CoinHandler?
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        //setting support button attributes
        supportButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        supportButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        supportButton.layer.shadowOpacity = 1.0
        supportButton.layer.shadowRadius = 0.0
        supportButton.layer.cornerRadius = 10
        
        fiatPicker.delegate = self
        fiatPicker.dataSource = self
        sortTypePicker.delegate = self
        sortTypePicker.dataSource = self
        
        let sortType = defaults.string(forKey: "sortType")//getting stored sort type
        let row = coinHandler?.sortTypes!.firstIndex(of: (sortType ?? coinHandler?.byMarketCap)!)//getting the index of the stored sort type
        
        sortTypePicker.selectRow(row ?? 0, inComponent: 0, animated: true)//setting the default selection of the sort type picker
        fiatPicker.selectRow(ExchangeRateData.fiatCurrencies.firstIndex(of: defaults.string(forKey: "fiat")!) ?? 1, inComponent: 0, animated: true)//setting the default selection of the fiat picker
        super.viewDidLoad()
    }
    
    @IBAction func reviewButtonPressed(_ sender: Any) {
        rateApp()
    }
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()

        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "1517180079") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

//MARK: - Currency Selector UIPickerDelegate
extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == fiatPicker){
            return ExchangeRateData.fiatCurrencies.count
        }
        else{
            return (coinHandler?.sortTypes!.count)!
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow component: Int) -> Int {
        if (pickerView == fiatPicker){
            return ExchangeRateData.fiatCurrencies.count
        }
        else{
            return (coinHandler?.sortTypes!.count)!
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == fiatPicker){
            return ExchangeRateData.fiatCurrencies[row]
        }else{
            return coinHandler?.sortTypes![row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == fiatPicker){
            coinHandler?.setCurrency(to: ExchangeRateData.fiatCurrencies[row])//setting currency to selected currency
        }else{
            coinHandler?.setSortType(to: (coinHandler?.sortTypes?[row])!)//setting sort type to selected sort type
        }
    }
    
}
