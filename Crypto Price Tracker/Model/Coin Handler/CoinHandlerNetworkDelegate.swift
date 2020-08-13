import Foundation
import Charts

/*
 Adopts the cryptoNetworkHandler
     - Receives coins data
         - Updates price
         - Updates 24H change
     - Recieves address balance data
         - Updates the address balance
 */
extension CoinHandler: cryptoNetworkHandlerDelegate{
    func failedToFetchDataForCoin() {
        numberOfCoinsFailedToFetchData += 1
    }
    
    func updateCoinData(){
        numberOfCoinsFailedToFetchData = 0
        if canUpdateCoinData{
            var isBitcoinLoaded: Bool = false
            for coin in loadedCoins{
                if (coin.id == "bitcoin"){
                    isBitcoinLoaded = true
                }
                if (coin.id != "native-currency"){
                    cryptoNetworkHandler.fetchCoinData(usingID: coin.id)
                }
            }
            if (!isBitcoinLoaded){
                cryptoNetworkHandler.fetchCoinData(usingID: "bitcoin")
            }
        }
    }
    
    @objc func canUpdateCoinDataTimerComplete() {
        updatedCoinDataTimer?.invalidate()
        canUpdateCoinData = true
    }
    
    func didUpdateCoinData(_ networkHandler: CryptoNetworkHandler, coinData: CoinData){
        DispatchQueue.main.async {
            if (coinData.data[CoinData.idKey] == "bitcoin"){
                self.priceOfBTCInUSD = Double(coinData.data[CoinData.priceKey]! ?? "0.0") ?? 0.0
            }
            for index in 0..<self.loadedCoins.count{
                if (self.loadedCoins[index].id == coinData.data[CoinData.idKey]){//finding coin in loaded coins
                    self.numOfUpdatedCoins += 1
                    let price: Double = Double(coinData.data[CoinData.priceKey]! ?? "0.0") ?? 0.0
                    self.loadedCoins[index].setPriceUSD(to: price)//updating price of coin
                    let change24H = Double(coinData.data[CoinData.change24HKey]! ?? "+0%") ?? 0.0
                    self.loadedCoins[index].setChange24H(to: change24H)//updating 24 chour change of coin
                    let marketCap: Double = Double(coinData.data[CoinData.mareketCapKey]! ?? "0.0") ?? 0.0
                    self.loadedCoins[index].setMarketCap(to: marketCap)
                }
            }
            if (self.numOfUpdatedCoins == self.loadedCoins.count - self.numberOfCoinsFailedToFetchData) || (self.isNativeCurrencyCoinLoaded == true && self.numOfUpdatedCoins == self.loadedCoins.count - self.numberOfCoinsFailedToFetchData - 1){
                self.canUpdateCoinData = false
                self.updatedCoinDataTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.canUpdateCoinDataTimerComplete), userInfo: nil, repeats: false)
                self.numOfUpdatedCoins = 0
                self.numberOfCoinsFailedToFetchData = 0
                self.sortLoadedCoins()
                self.updatePieChartEntries()
                self.delegate?.handleRefreshNow()
            }
        }
    }
    
    func updateAddressBalances(){
        for i in 0..<loadedCoins.count{
            if (Coin.coinsWithAutomaticAddressRefresh.contains(loadedCoins[i].id)){//checking if coin supports having address
                loadedCoins[i].setAddressBalance(forAddressNumber: 1, to: 0)//resetting address balances
                loadedCoins[i].setAddressBalance(forAddressNumber: 2, to: 0)
            }
        }
        
        for i in 1...2{
            if let address = defaults.string(forKey: "BTCaddress\(i)"){//getting addresses from defaults
                cryptoNetworkHandler.fetchAddressBalance(usingID: "bitcoin", usingAddress: address, addressNumber: i)//fetching balance
                
            }
            if let address = defaults.string(forKey: "ETHaddress\(i)"){
                cryptoNetworkHandler.fetchAddressBalance(usingID: "ethereum", usingAddress: address, addressNumber: i)
            }
        }
    }
    
    func didUpdateAddressBalances(_ networkHandle: CryptoNetworkHandler, balanceData: BalanceData) {
        for i in 0..<loadedCoins.count{
            if loadedCoins[i].id == balanceData.id{//finding coin in loaded coins
                loadedCoins[i].setAddressBalance(forAddressNumber: balanceData.addressNumber ?? 0, to: balanceData.getBalance())//setting address balance
            }
        }
        updatePieChartEntries()
        sortLoadedCoins()
        delegate?.handleRefreshNow()
        didUpdateAddressBalance = true
    }
    
    func updateExchangeRateData(){
        cryptoNetworkHandler.fetchExchangeRates()
    }
    
    func didUpdateExchangeRateData(_ networkHandler: CryptoNetworkHandler, exchangeRateData: ExchangeRateData) {
        self.selectedExchangeRateAgainstUSD = exchangeRateData.rates[defaults.string(forKey: "fiat") ?? "USD"] ?? 1.0
        self.delegate?.handleRefreshNow()
    }
    
    func didFailWithError(error: Error) {print(error)}
}
