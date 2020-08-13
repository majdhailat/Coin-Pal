import UIKit
/*
 View controller for the edit coins screen
 Contians the table view of all the coins

 */
class EditCoinsViewController: UIViewController, UpdateDelegate{
    func didUpdate() {
        tableView.reloadData()
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let defaults = UserDefaults.standard
    var coinHandler: CoinHandler?
    let allCoins: [String] = Coin.IDs//all coins
    var searchArray = [String]()//the array of coins of coins that satisfy the users search term
    var isSearching: Bool = false//if the user is currently searching
    var coinsArray:[String]!//becomes either the search array or all coins array
    
    override func viewDidLoad() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        coinHandler?.updateDelegate = self
        super.viewDidLoad()
    }
}

//MARK: - UITableView Delegate
extension EditCoinsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching){
            return searchArray.count
        }else{
            return allCoins.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCoinsCustomCell") as! EditCoinsTableViewCell
        if (isSearching){//setting coins array to search array or all coins array depending on if the user is searching
            coinsArray = searchArray
        }else{
            coinsArray = allCoins
        }
        
        let coinID: String = coinsArray[indexPath.row]
        cell.iconImage.image = UIImage(named: coinID)//setting icon of cell
        cell.nameLabel.text = Coin.coinNames[coinID]//setting name of cell
        cell.tickerLabel.text = Coin.coinTickers[coinID]//setting ticker of cell
        
        if coinHandler!.premiumEnabled == false && Coin.isCoinPremium(id: coinID)!{
            cell.nameLabel.isEnabled = false
            cell.tickerLabel.isEnabled = false
        }else{
            cell.nameLabel.isEnabled = true
            cell.tickerLabel.isEnabled = true
        }
        
        cell.coinActiveSwitch.isOn = false//setting the cells switch to off by default
        for (id, _) in defaults.dictionary(forKey: "coins") as! [String: Double]{//searching for for the coin in the user defaults
            if id == coinsArray[indexPath.row]{//coin was found meaning the switch should be on
                cell.coinActiveSwitch.isOn = true//flipping switch to on
            }
        }
        
        cell.coinActiveSwitch.tag = indexPath.row//tagging the cell with the index of the coin in the coins array
        cell.coinActiveSwitch.addTarget(self, action: #selector(self.switchTriggered(_: )), for: .valueChanged );//checks if the user clicks on the switch and calls the switch triggered method
        return cell
    }
    
    /*
     gets called when the user presses on a switch in a cell
     */
    @objc func switchTriggered(_ sender: UISwitch){
        let coinID: String = coinsArray[sender.tag]//getting the coin id using the cells tag
        if coinHandler!.premiumEnabled == true || Coin.isCoinPremium(id: coinID)! == false{
            if (sender.isOn == false){//switch was switched off
                coinHandler?.removeCoin(withID: coinID)//removing coin from user defaults & loaded coins
            }else{//switch was switched on
                coinHandler?.addCoin(withID: coinID)//adding coin to user defaults & loaded coins
            }
        }else{
            coinHandler?.buyPremium()
            sender.isOn = !sender.isOn
        }
    }
    
    /*
     Returns the cells height
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

//MARK: - UISearchBar Delegate
extension EditCoinsViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchArray = allCoins.filter({Coin.coinNames[$0]!.lowercased() .prefix(searchText.count) == searchText.lowercased()})//adding coins that have a name that satisfies search
        searchArray.append(contentsOf: allCoins.filter({Coin.coinTickers[$0]!.lowercased() .prefix(searchText.count) == searchText.lowercased()}))//adding coins that have a ticker that satisfies search
        
        searchArray.removeDuplicates()//removing duplicates (ticker and name satisfy the search)
        
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
}

//MARK: - array extension
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
