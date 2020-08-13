import Foundation
/*
 Handles the networking
    - Fetches the coin data
    - Fetches the address balances
    - Parses the data into the correct data objects (BalanceData/ CoinData)
 */

class CryptoNetworkHandler{
    var delegate: cryptoNetworkHandlerDelegate?
    
    /*
     Takes the id of a coin and a fiat currency (currently unused) and creates a network request for their data
     */
    func fetchCoinData(usingID id: String){
        let url: String = "https://api.coincap.io/v2/assets/\(id)"
        performRequest(with: url, requestType: "getData")
    }
    
    /*
     Takes the id of a coin, the public address of the coin and the address number (1 or 2) and creates a network request for the balance
     */
    func fetchAddressBalance(usingID id: String, usingAddress address: String, addressNumber: Int){
        if var ticker: String = Coin.coinTickers[id]{//getting coin ticker
            ticker = ticker.lowercased()
            let url: String = "https://api.blockcypher.com/v1/\(ticker)/main/addrs/\(address)"
            performRequest(with: url, requestType: "getBalance \(id) \(addressNumber)")
        }
    }
    
    /*
    Creates a network request for the exchange rates
    */
    func fetchExchangeRates(){
        let url: String = "https://api.exchangeratesapi.io/latest?base=USD"
        performRequest(with: url, requestType: "getExchangeRates")
    }
    
    /*
     Creates a network request for the data of all coins in the api **UNUSED IN APP**
     */
    func fetchAllCoinData(){
        let url: String = "https://api.coincap.io/v2/assets/"
        performRequest(with: url, requestType: "all")
    }
    /*
     Takes a url and a request type (data or balance) and performs the network request
     Updates the delegate with the network data
     */
    func performRequest(with urlString: String, requestType: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    if (requestType == "getData"){
                        self.delegate?.didFailWithError(error: error!)
                    }else{
                        self.delegate?.didFailWithError(error: error!)
                    }
                    return
                }
                
                if (requestType == "getData"){//checking request type
                    if let safeData = data{
                        if let coinData:CoinData = self.parseJSON(safeData){//parsing data into CoinData object
                            self.delegate?.didUpdateCoinData(self, coinData: coinData)//updating delegate with data
                        }
                    }
                }
                else if (requestType == "all"){
                    if let safeData = data{
                        if let _: AllData = self.parseJSON(safeData){
                                
                        }
                    }
                }
                else if (requestType == "getExchangeRates"){
                    if let safeData = data{
                        if let exchangeRateData: ExchangeRateData = self.parseJSON(safeData){
                            self.delegate?.didUpdateExchangeRateData(self, exchangeRateData: exchangeRateData)
                        }
                    }
                }
                else{
                    let requestTypeArray = requestType.components(separatedBy: " ")//splitting the request type
                    if let safeData = data{
                        if var balanceData:BalanceData = self.parseJSON(safeData){//parsing data into BalanceData object
                            let id: String = requestTypeArray[1]//getting the coin id from the request type
                            balanceData.id = id//setting the coin id of the balance model
                            let addressNumber: Int = Int(requestTypeArray[2]) ?? 0//getting the address number from the request type
                            balanceData.addressNumber = addressNumber//updating the balance model with the address number
                            self.delegate?.didUpdateAddressBalances(self, balanceData: balanceData)//updating delegate with data
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    /*
     Takes data in json format and returns balance model
     */
    func parseJSON(_ data: Data) -> BalanceData?{
        let decoder = JSONDecoder()
        do{
            let balanceData:BalanceData = try decoder.decode(BalanceData.self, from: data)//decoding data into BalanceDataObject
            return balanceData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSON(_ data: Data) -> CoinData?{
        let decoder = JSONDecoder()
        do{
            let coinData = try decoder.decode(CoinData.self, from: data)//decoding data into CoinData object
            return coinData
        }catch{
            delegate?.failedToFetchDataForCoin()
            return nil
        }
    }
    
    func parseJSON(_ data: Data) -> ExchangeRateData?{
        let decoder = JSONDecoder()
        do{
            let exchangeRateData = try decoder.decode(ExchangeRateData.self, from: data)//decoding data into ExchangeRateData object
            return exchangeRateData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    func parseJSON(_ data: Data) -> AllData?{
        let decoder = JSONDecoder()
        do{
            let allData = try decoder.decode(AllData.self, from: data)//decoding data into AllData object
            return allData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

protocol cryptoNetworkHandlerDelegate{
    func didUpdateCoinData(_ networkHandler: CryptoNetworkHandler, coinData: CoinData)
    func didUpdateAddressBalances(_ networkHandle: CryptoNetworkHandler, balanceData: BalanceData)
    func didUpdateExchangeRateData(_ networkHandler: CryptoNetworkHandler, exchangeRateData: ExchangeRateData)
    func didFailWithError(error: Error)
    func failedToFetchDataForCoin()
}
