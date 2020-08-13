import Charts
import UIKit
import CoreImage
import StoreKit
/*
 Manges coin data stored in the user defaults
 Loads coins from user defaults and manges loaded coins
    - Handles the adding/ removing of coins
    - Updates the manual balance of coins
    - Updates the addresses for supported coins (bitcoin and ethereum for now)
    - Calculates the total balance of all loaded coins in USD and BTC
    - Updates the preferred currency and the preferred sort type
    - Sorts the coins by the users selected sort type
    - Creates the data necessary for the pie chart 
 */

class CoinHandler: NSObject, SKPaymentTransactionObserver{
    let cryptoNetworkHandler = CryptoNetworkHandler()
    var delegate: CoinHandlerDelegate?
    var updateDelegate: UpdateDelegate?
    let defaults = UserDefaults.standard
    let productID = "coinPalPremium"
    var loadedCoins:[Coin] = []//coins visible to the user from the main screen
    var isNativeCurrencyCoinLoaded: Bool = false
    var priceOfBTCInUSD: Double?
    
    var selectedExchangeRateAgainstUSD: Double = 1//the currently enabled exchange rate multipler
    
    var canUpdateCoinData: Bool = true//if the coin data can be re-updated
    var updatedCoinDataTimer: Timer?//used to toggle the canUpdateCoinData to true after timer runs out
    var numOfUpdatedCoins: Int = 0//the number of coins whose data was received, used to determine when to refresh the view
    var numberOfCoinsFailedToFetchData: Int = 0
    var didUpdateAddressBalance: Bool = false
    
    let byMarketCap = "Market Cap", byPrice = "Price", byChange24H = "24H Change", byName = "Name", byBalanceValue = "Portfolio Value"//different sort types
    var sortTypes: [String]?
    
    var premiumEnabled: Bool{
        get{
            return defaults.bool(forKey: productID)
            
        }set{
            defaults.set(true, forKey: productID)
        }
    }
    
    override init() {
        super.init()
        sortTypes = [byChange24H, byMarketCap, byBalanceValue, byName, byPrice]
        Coin.initDictionaries()
        if defaults.bool(forKey: "init") == false{//checking if first boot
            self.initializeDefaults()
        }
        if defaults.bool(forKey: "postPremium") == false{
            self.removePremiumCoins();
        }
        loadCoinsFromDefaults()
        updateCoinData()
        cryptoNetworkHandler.delegate = self
        updateAddressBalances()
        updateExchangeRateData()
        SKPaymentQueue.default().add(self)
    }
    
    /*
     Called when the app is loaded for the first time
     Creates placeholders for addresses in defaults
     Adds default coins to defaults
     */
    func initializeDefaults(){
        defaults.set(nil, forKey: "BTCaddress1")
        defaults.set(nil, forKey: "BTCaddress2")
        defaults.set(nil, forKey: "ETHaddress1")
        defaults.set(nil, forKey: "ETHaddress2")
        //                      ID      BALANCE
        let cryptoCurrencies:[String: Double] = ["bitcoin" : 0,
                                                "ethereum" : 0,
                                                "ripple" : 0]
                                    
        defaults.set(cryptoCurrencies, forKey: "coins")
        defaults.set(("USD"), forKey: "fiat")
        defaults.set(byMarketCap, forKey: "sortType")
        defaults.set(true, forKey: "postPremium")
        defaults.set(true, forKey: "init")
    }
    
    func removePremiumCoins(){
        var usersCoins: [String: Double] = defaults.dictionary(forKey: "coins") as! [String: Double]
        for (id, _) in usersCoins{
            guard let isPremium = Coin.isCoinPremium(id: id) else {
                fatalError("Coin ID does not exist")
            }
            if isPremium{
                usersCoins[id] = nil
            }
        }
        defaults.set(usersCoins, forKey: "coins")//updating user defaults with dictionary
        defaults.set(true, forKey: "postPremium")
    }
    
    /*
     Gets coin data from defaults and creates coin objects to store in the loaded coins array
     */
    func loadCoinsFromDefaults(){
        for (id, balance) in defaults.dictionary(forKey: "coins") as! [String: Double]{
            let coin = Coin(id: id, manualBalance: balance)
            if coin.id == Coin.nativeCurrencyCoinID{
                isNativeCurrencyCoinLoaded = true
            }
            loadedCoins.append(coin)
        }
        updatePieChartEntries()
    }
    
    /*
     Takes the id of a coin
     If the coin supports having an address: fetches the balance of all addresses (not just this coin)
     Adds the coin to the user defaults and the loaded coins array
     */
    func addCoin(withID id: String){
        if (Coin.coinsWithAutomaticAddressRefresh.contains(id)){
            updateAddressBalances()
        }
        if (id == Coin.nativeCurrencyCoinID){
            isNativeCurrencyCoinLoaded = true
        }
        var usersCoins: [String: Double] = defaults.dictionary(forKey: "coins") as! [String: Double]
        usersCoins[id] = 0//creating a new dictionary entry for the coin with a 0 balance
        defaults.set(usersCoins, forKey: "coins")//updating user defaults with dictionary
        //creating new coin object for the coin
        let coin = Coin(id: id, manualBalance: 0)
        loadedCoins.append(coin)
        sortLoadedCoins()
        self.numOfUpdatedCoins = loadedCoins.count - 1
        cryptoNetworkHandler.fetchCoinData(usingID: id)//fetching coin data
        self.delegate?.handleRefreshNow()
    }
    
    /*
     Takes the id of a coin
     Removes the coin from the user defaults and the loaded coins array
     */
    func removeCoin(withID id: String){
        if (id == Coin.nativeCurrencyCoinID){
            isNativeCurrencyCoinLoaded = false
        }
        var usersCoins: [String: Double] = defaults.dictionary(forKey: "coins") as! [String: Double]
        usersCoins[id] = nil//removing from dictionary in user defaults
        defaults.set(usersCoins, forKey: "coins")//updating user defaults with dictionary
        for i in 0..<loadedCoins.count{
            if (loadedCoins[i].id == id){//finding coin in loaded coins
                loadedCoins.remove(at: i)//removing coin from loaded coins
                break
            }
        }
        updatePieChartEntries()
        self.delegate?.handleRefreshNow()
    }
    
    /*
     Takes the id of a coin and the new manual balance
     */
    func updateManualBalance(of id: String, to balance: Double){
        var usersCoins: [String: Double] = defaults.dictionary(forKey: "coins") as! [String: Double]
        usersCoins[id] = balance//updating balance in user defaults
        defaults.set(usersCoins, forKey: "coins")//updating user defaults with dictionary
        for i in 0..<loadedCoins.count{
            if (loadedCoins[i].id == id){//finding coin in loaded coins
                loadedCoins[i].setManualBalance(to: balance)//updating coins manual balance
            }
        }
        sortLoadedCoins()
        updatePieChartEntries()
        self.delegate?.handleRefreshNow()
    }
    
    /*
     Takes the id of a coin and a amount to add (negative amount to subtract) and adds it to the balance
     */
    func addToManualBalance(of id: String, amount: Double){
        var usersCoins: [String: Double] = defaults.dictionary(forKey: "coins") as! [String: Double]
        if (usersCoins[id] != nil){
            usersCoins[id]! += amount//adding amount to balance in user defaults
            usersCoins[id]! = (usersCoins[id]! * 100000000).rounded()/100000000
        }else{
            usersCoins[id] = amount
        }
        if (usersCoins[id]! >= 0.0){//checking if the resultant balance is not negative
            defaults.set(usersCoins, forKey: "coins")//updating user defaults with dictionary
            for i in 0..<loadedCoins.count{
                if (loadedCoins[i].id == id){//finding coin in loaded coins
                    loadedCoins[i].addToManualBalance(amount: amount)//adding amount to the loaded coins balance
                }
            }
            sortLoadedCoins()
            updatePieChartEntries()
            self.delegate?.handleRefreshNow()
        }
    }
    
    /*
     Takes the id of a coin (only works for bitcoin or ethereum for now), the new address of the coin and the address number (1 or 2)
     */
    func updateAddress(of id: String, to address: String?, addressNumber: Int){
        if (addressNumber == 1 || addressNumber == 2){
            if (id == "bitcoin"){
                defaults.set(address, forKey: "BTCaddress\(addressNumber)")//updating address in defaults
            }
            else if (id == "ethereum"){
                defaults.set(address, forKey: "ETHaddress\(addressNumber)")
            }
            updateAddressBalances()//refreshing address balances
            updatePieChartEntries()
            self.delegate?.handleRefreshNow()
        }
    }
    
    /*
     Rreturn the total balance of all loaded coins (manul balance + address balances)
     */
    func getTotalBalanceValue(rateAgainstUSD: Double) -> Double{
        var totalBalance: Double = 0
        for i in 0..<loadedCoins.count{
            totalBalance += loadedCoins[i].getBalanceValue(withExchangeRate: rateAgainstUSD) ?? 0//adding balance of each coin
        }
        return totalBalance
    }
    
    /*
     Returns the total balance of all loaded coins in BTC
     */
    func getTotalBalanceValueInBTC() -> Double{
        var totalBalance: Double = 0
        for i in 0..<loadedCoins.count{
            if loadedCoins[i].id != Coin.nativeCurrencyCoinID{
                totalBalance += loadedCoins[i].getBalanceValue(withExchangeRate: 1) ?? 0//adding balance of each coin
            }
        }
        if isNativeCurrencyCoinLoaded{
            for i in 0..<loadedCoins.count{
                if loadedCoins[i].id == Coin.nativeCurrencyCoinID{
                    totalBalance += ((loadedCoins[i].getBalanceValue(withExchangeRate: 1) ?? 0) / selectedExchangeRateAgainstUSD)
                }
            }
        }
        
        return totalBalance / (priceOfBTCInUSD ?? 1)
    }
    
    /*
     Takes a currency symbol as a string
     Updates the defaults with the new currency
     Updates the exchange rates -> refreshes the displayed prices
     */
    func setCurrency(to currency: String){
        defaults.set(currency, forKey: "fiat")
        Coin.coinTickers[Coin.nativeCurrencyCoinID] = currency
        if isNativeCurrencyCoinLoaded{
            for i in 0..<loadedCoins.count{
                if loadedCoins[i].id == Coin.nativeCurrencyCoinID{
                    let newCoin: Coin  = Coin(id: Coin.nativeCurrencyCoinID, manualBalance: loadedCoins[i].getBalance())
                    loadedCoins[i] = newCoin
                }
            }
        }
        cryptoNetworkHandler.fetchExchangeRates()
    }
    
    /*
     Takes a sort type as a string
     Updates the defaults with the new sort type
     Resorts the coins
     Refreshes the coins
     */
    func setSortType(to sortType: String){
        defaults.set(sortType, forKey: "sortType")
        sortLoadedCoins()
        delegate?.handleRefreshNow()
    }
    
    /*
     Sorts the loaded coins array using the sort type stored in the defaults
     */
    func sortLoadedCoins(){
        let sortType: String = defaults.string(forKey: "sortType") ?? byMarketCap//getting sort type
        loadedCoins = loadedCoins.sorted { $0.getMarketCap() ?? 0 > $1.getMarketCap() ?? 0 }
        if (sortType == byName){
            loadedCoins = loadedCoins.sorted { $0.name.lowercased() < $1.name.lowercased() }//sorting coins
        }
        else if (sortType == byMarketCap){
            loadedCoins = loadedCoins.sorted { $0.getMarketCap() ?? 0 > $1.getMarketCap() ?? 0 }
        }
        else if (sortType == byPrice){
            loadedCoins = loadedCoins.sorted { $0.getPrice(withExchangeRate: 1) ?? 0 > $1.getPrice(withExchangeRate: 1) ?? 0 }
        }
        else if (sortType == byChange24H){
            loadedCoins = loadedCoins.sorted { $0.getChange24H() ?? 0 > $1.getChange24H() ?? 0 }
        }
        else if (sortType == byBalanceValue){
            loadedCoins = loadedCoins.sorted { $0.getBalanceValue(withExchangeRate: 1) ?? 0 > $1.getBalanceValue(withExchangeRate: 1) ?? 0 }
        }
    }
    
    /*
     Creates a set of data for the pie chart using the balance values of the coins and the colors of the coins icons
     Updates the delegates pie chart with the new data set
     */
    func updatePieChartEntries(){
        DispatchQueue.main.async {
            var pieChartEntries: [PieChartDataEntry] = [PieChartDataEntry]()//the coin values for the pie chart
            var pieChartEntryColors: [UIColor] = [UIColor]()//color values for the pie chart
            let loadedCoinsSortedByBalanceValue = self.loadedCoins.sorted { $0.getBalanceValue(withExchangeRate: 1) ?? 0 > $1.getBalanceValue(withExchangeRate: 1) ?? 0 }//getting all loaded coins sorted by balance
            for i in 0..<loadedCoinsSortedByBalanceValue.count{
                let coin : Coin = loadedCoinsSortedByBalanceValue[i]
                if let balance = coin.getBalanceValue(withExchangeRate: 1){//getting balance value in USD
                    if balance != 0{
                        let entry: PieChartDataEntry = PieChartDataEntry(value: balance)//creating entry
                        pieChartEntries.append(entry)
                        let col: UIColor = (UIImage(named: coin.id)?.averageColor) ?? UIColor.black//getting the color of the entry by avergaing the color of the coins icon
                        col.withAlphaComponent(1)
                        pieChartEntryColors.append(col)
                    }
                }
            }
            if (pieChartEntries.count == 0){//no coins have a balance
                pieChartEntries.append(PieChartDataEntry(value: 1))//adding a single entry to fill the chart
                pieChartEntryColors.append(UIColor.black)
            }
            let chartDataSet = PieChartDataSet(entries: pieChartEntries, label: nil)//new data set
            chartDataSet.colors = pieChartEntryColors//setting colors for data
            chartDataSet.drawValuesEnabled = false
            let chartData = PieChartData(dataSet: chartDataSet)//new data with data set
            self.delegate?.setPieChartData(data: chartData)//updating pie chart with new data
        }
    }
    //MARK: - In App Purchase
    func buyPremium(){
        if SKPaymentQueue.canMakePayments(){
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            if transaction.transactionState == .purchased || transaction.transactionState == .restored{
                premiumEnabled = true
                updateDelegate?.didUpdate()
                SKPaymentQueue.default().finishTransaction(transaction)
            }else if transaction.transactionState == .failed{
                SKPaymentQueue.default().finishTransaction(transaction )
            }
        }
    }
}


//MARK: - UIImage Extension
extension UIImage {
    /*
     Returns the avergae color of an image
     */
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: 0.65)//alpha: CGFloat(bitmap[3]) / 255
    }
}

protocol CoinHandlerDelegate {
    func handleRefreshNow()
    func setPieChartData(data: PieChartData)
}

protocol UpdateDelegate{
    func didUpdate()
}
