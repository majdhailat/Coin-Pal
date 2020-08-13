import Foundation
import UIKit
/*
Manges the automatic and manual balance text fields
Updates the balance through the coin handler
 */
extension PortfolioViewController: UITextFieldDelegate{
    @IBAction func searchPressed(_ sender: UIButton) {
        manualBalanceTextField.endEditing(true)
        address1TextField.endEditing(true)
        address2TextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        manualBalanceTextField.endEditing(true)
        address1TextField.endEditing(true)
        address2TextField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //manual balance
        if (textField == manualBalanceTextField){
            if let balance: Double = Double(textField.text!){//checking if inputted balance is valid
                coinHandler?.updateManualBalance(of: coinID! , to: balance)//updating balance
                textField.placeholder = textField.text//setting balance as the placeholder
                textField.text = ""//clearing text field
            }else{//invalid input
                textField.placeholder = "Enter your balance"//setting place holder as default text
                coinHandler?.updateManualBalance(of: coinID! , to: 0)//resetting balance to 0
            }
        }else{//automnatic balance
            var addressNumber: Int?//the address number (1 or 2)
            switch textField{//getting right address number
            case address1TextField:
                addressNumber = 1
            default:
                addressNumber = 2
            }
            
            if (textField.text == ""){//checking if the user cleared the text
                textField.placeholder = "Public address \(addressNumber!)"//setting place holder as default text
                coinHandler?.updateAddress(of: coinID!, to: nil, addressNumber: addressNumber!)//resetting address
            }else{
                if (textField.placeholder != textField.text){//checking if the text changed
                    textField.placeholder = textField.text//setting place holder text as the address
                    coinHandler?.updateAddress(of: coinID!, to: textField.text!, addressNumber: addressNumber!)//updating the address
                }
            }
            textField.text = ""//clearing text
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //manual balance
        if textField == manualBalanceTextField{
            if (textField.placeholder != "Enter your balance"){//checking that the place holder text is not the default text
                textField.text = textField.placeholder//setting the text as the place holder text
            }
        }else{//autonatic balance
            if (textField.placeholder != "Public address 1" && textField.placeholder != "Public address 2"){
                textField.text = textField.placeholder
            }
        }
    }
}
