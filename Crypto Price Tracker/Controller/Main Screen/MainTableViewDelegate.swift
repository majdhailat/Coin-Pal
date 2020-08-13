import Foundation
import UIKit
/*
 Fills in the information of all the cell elements with the proper data from each coin
 Contains methods to properly format the coin data for display
 */
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /*
     Returns the number of rows (# of loaded coins) in the table view
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinHandler.loadedCoins.count
    }
    
    /*
      Fills in the information of all the cell elements with the proper data from each coin
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let coin: Coin = coinHandler.loadedCoins[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! LoadedCoinTableViewCell
        cell.tag = indexPath.row//tagging the cell with the index of the coin in the loaded coins array
        //roudning the corners of the cell
        cell.cellView.layer.cornerRadius = 20
        cell.layer.cornerRadius = 20
        //setting the selection style of the cell
        let customColorView: UIView = UIView()
        customColorView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3009952911)
        cell.selectedBackgroundView = customColorView
        //filling all the labels/images of the cell
        cell.iconImage.image = UIImage(named: coin.id)
        cell.iconImage.layer.cornerRadius = cell.iconImage.frame.height/2
        cell.nameLabel.text = coin.name
        cell.tickerLabel.text = coin.ticker
        cell.priceLabel.text = getPriceLabelText(of: coin)
        cell.balanceLabel.text = getBalaneLabelText(of: coin)
        cell.balanceValueLabel.text = getBalanceValueLabelText(of: coin)
        cell.change24H.textColor = getChange24HLabelColor(of: coin)
        cell.change24H.text = getChange24HLabelText(of: coin)
        return cell
    }
    
    /*
     Returns the height of each row
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    /*
     Returns formatted price as string
     */
    func getPriceLabelText(of coin: Coin) -> String{
        let price: Double = coin.getPrice(withExchangeRate: coinHandler.selectedExchangeRateAgainstUSD) ?? 0.0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if (price < 0.1){
            numberFormatter.minimumSignificantDigits = 3
            numberFormatter.maximumSignificantDigits = 3
        }else{
            numberFormatter.maximumFractionDigits = 3
        }
        let formattedPrice = "$\(numberFormatter.string(from: NSNumber(value: price)) ?? "0.00")"
        return formattedPrice
    }
    
    /*
     Returns formatted balance as string
     */
    func getBalaneLabelText(of coin: Coin) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 8
        if coin.getBalance() == 0{
            return ""
        }else{
            
            return String(numberFormatter.string(from: NSNumber(value: coin.getBalance()))!)
        }
    }
    
    /*
    Returns formatted balance value as string
    */
    func getBalanceValueLabelText(of coin: Coin) -> String{
        if (coin.getBalance() == 0){
            return ""
        }else{
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 2
            let formatedBalanceValue:String = "$\(String(numberFormatter.string(from: NSNumber(value: coin.getBalanceValue(withExchangeRate: coinHandler.selectedExchangeRateAgainstUSD) ?? 0.0))!))"
            
            return formatedBalanceValue
        }
    }
    
    /*
    Returns formatted 24h change as string
    */
    func getChange24HLabelText(of coin: Coin) -> String{
        let change24H: Double = coin.getChange24H() ?? 0.0
        if (change24H >= 0){
            return "+\(String(format: "%.2f", change24H))%"
        }else{
            return "\(String(format: "%.2f", change24H))%"
        }
    }
    
    /*
    Returns formatted label color as UIColor
    */
    func getChange24HLabelColor(of coin: Coin) -> UIColor{
        let change24H: Double = coin.getChange24H() ?? 0.0
        if (change24H >= 0){
            if traitCollection.userInterfaceStyle == .light{
                return #colorLiteral(red: 0, green: 0.5080381632, blue: 0, alpha: 1)
            }else{
                return #colorLiteral(red: 0, green: 0.7830973627, blue: 0, alpha: 1)
            }
        }else{
            if traitCollection.userInterfaceStyle == .light{
                return #colorLiteral(red: 0.5459952354, green: 0.06263076514, blue: 0.008274512365, alpha: 1)
            }else{
                return #colorLiteral(red: 0.900577911, green: 0.1491314173, blue: 0, alpha: 1)
            }
        }
    }
}
