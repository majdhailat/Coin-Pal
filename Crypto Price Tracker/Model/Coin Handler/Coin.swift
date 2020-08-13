import Foundation
/*
 Contains all the information about a coin
 Contains static information about all the availble coins
 */

struct Coin{
    let id: String
    let name: String
    let ticker: String
    private var manualBalance: Double
    private var address1Balance: Double?
    private var address2Balance: Double?
    private var price: Double?
    private var change24H: Double?
    private var marketCap: Double?
    
    init(id: String, manualBalance: Double) {
        self.id = id
        self.name = Coin.coinNames[id] ?? ""
        self.ticker = Coin.coinTickers[id] ?? ""
        self.manualBalance = manualBalance
    }
    
    /*
     Loads dictinaries for easy access to coin names and tickers using coin ID
     */
    static func initDictionaries(){
        let defaults = UserDefaults.standard
        for i in 0..<IDs.count{
            if (IDs[i] == Coin.nativeCurrencyCoinID){
                coinNames[IDs[i]] = "Native Currency"
                coinTickers[IDs[i]] = defaults.string(forKey: "fiat") ?? "USD"
            }else{
                coinNames[IDs[i]] = names[i]
                coinTickers[IDs[i]] = tickers[i]
            }
        }
    }
    
    /*
     Returns the total balance of this coin
     */
    func getBalance() -> Double{
        return manualBalance + (address1Balance ?? 0) + (address2Balance ?? 0)
    }
    
    /*
    Sets the manual balance
     */
    mutating func setManualBalance(to balance: Double){
        manualBalance = balance
    }
    
    /*
     Adds a specified amount to the manual balance
     To subtract, input a negative value
     */
    mutating func addToManualBalance(amount: Double){
        manualBalance += amount
        manualBalance = (manualBalance * 100000000).rounded()/100000000
    }
    
    /*
     Takes an address number (1 or 2) and a balance and sets the balance of the address
     */
    mutating func setAddressBalance(forAddressNumber addressNumber: Int, to balance: Double){
        if (addressNumber == 1){
            address1Balance = balance
        }else if (addressNumber == 2){
            address2Balance = balance
        }
    }
    
    /*
     Returns the value of the balance of this coin
     */
    func getBalanceValue(withExchangeRate rate: Double) -> Double?{
        if (id == Coin.nativeCurrencyCoinID){
            return getBalance()
        }
        if (price != nil){
            return getPrice(withExchangeRate: rate)! * getBalance()
        }
        return nil
    }
    
    /*
     Sets the price
     */
    mutating func setPriceUSD(to price: Double){
        self.price = price
    }
    
    /*
     Returns the price
     */
    func getPrice(withExchangeRate rate: Double) -> Double?{
        if (id == Coin.nativeCurrencyCoinID){
            return 1.00
        }
        if (price != nil){
            return price! * rate
        }else{
            return nil
        }
    }
    
    /*
     Sets the 24H change
     */
    mutating func setChange24H(to change: Double){
        change24H = change
    }
    
    /*
     Rerurns the 24H change
     */
    func getChange24H() -> Double?{
        return change24H
    }
    
    /*
     Sets the market cap
     */
    mutating func setMarketCap(to marketCap: Double){
        self.marketCap = marketCap
    }
    
    /*
     Returns the market cap
     */
    func getMarketCap() -> Double?{
        return marketCap
    }
    
    static func isCoinPremium(id: String) -> Bool?{
        if let index = IDs.firstIndex(of: id){
            if index < numberOfNonPremiumCoins{
                return false
            }else{
                return true
            }
        }
        return nil
    }
    
    static let nativeCurrencyCoinID = "native-currency"
    static let coinsWithAutomaticAddressRefresh = ["bitcoin", "ethereum"]
        
    static var coinNames: [String: String] = [String: String]()//dictionary of the coin names with key: coinID
                                    
    static var coinTickers: [String: String] = [String: String]()//dictionary of the coin tickers with key: coinID
    
    static let numberOfNonPremiumCoins: Int = 5
    
    static let IDs: [String] = ["bitcoin", "ethereum", "tether", "ripple", "bitcoin-cash", "bitcoin-sv", "litecoin", "binance-coin", "eos", "tezos", "cardano", "chainlink", "stellar", "unus-sed-leo", "monero", "tron", "huobi-token", "ethereum-classic", "neo", "dash", "usd-coin", "cosmos", "iota", "zcash", "nem", "ontology", "maker", "dogecoin", "basic-attention-token", "omisego", "vechain", "paxos-standard-token", "digibyte", "0x", "theta-token", "icon", "qtum", "decred", "bitcoin-gold", "algorand", "lisk", "enjin-coin", "augur", "trueusd", "nano", "multi-collateral-dai", "ravencoin", "kyber-network", "monacoin", "waves", "zilliqa", "bitcoin-diamond", "siacoin", "status", "dxchain-token", "crypto-com", "holo", "unibright", "steem", "energi", "komodo", "nervos-network", "bytom", "abbc-coin", "hypercash", "ethlend", "seele", "nexo", "numeraire", "electroneum", "republic-protocol", "quant", "verge", "bitshares", "decentraland", "native-currency"]
    
    private static let names: [String] = ["Bitcoin", "Ethereum", "Tether", "XRP", "Bitcoin Cash", "Bitcoin SV", "Litecoin", "Binance Coin", "EOS", "Tezos", "Cardano", "Chainlink", "Stellar", "UNUS SED LEO", "Monero", "TRON", "Huobi Token", "Ethereum Classic", "Neo", "Dash", "USD Coin", "Cosmos", "IOTA", "Zcash", "NEM", "Ontology", "Maker", "Dogecoin", "Basic Attention Token", "OmiseGO", "VeChain", "Paxos Standard Token", "digibyte", "0x", "Theta Token", "ICON", "Qtum", "Decred", "Bitcoin Gold", "Algorand", "Lisk", "Enjin Coin", "Augur", "TrueUSD", "Nano", "Multi Collateral DAI", "Ravencoin", "Kyber Network", "MonaCoin", "Waves", "Zilliqa", "Bitcoin Diamond", "Siacoin", "Status", "DxChain Token", "MCO", "Holo", "Unibright", "Steem", "Energi", "Komodo", "Nervos Network", "Bytom", "ABBC Coin", "HyperCash", "ETHLend", "Seele-N", "Nexo", "Numeraire", "Electroneum", "Republic Protocol", "Quant", "Verge", "BitShares", "Decentraland", "Native Currency"]

    private static let tickers: [String] = ["BTC", "ETH", "USDT", "XRP", "BCH", "BSV", "LTC", "BNB", "EOS", "XTZ", "ADA", "LINK", "XLM", "LEO", "XMR", "TRX", "HT", "ETC", "NEO", "DASH", "USDC", "ATOM", "MIOTA", "ZEC", "XEM", "ONT", "MKR", "DOGE", "BAT", "OMG", "VET", "PAX", "DGB", "ZRX", "THETA", "ICX", "QTUM", "DCR", "BTG", "ALGO", "LSK", "ENJ", "REP", "TUSD", "NANO", "DAI", "RVN", "KNC", "MONA", "WAVES", "ZIL", "BCD", "SC", "SNT", "DX", "MCO", "HOT", "UBT", "STEEM", "NRG", "KMD", "CKB", "BTM", "AABC", "HC", "LEND", "SEELE", "NEXO", "NMR", "ETN", "REN", "QNT", "XVG", "BTS", "MANA", "NAT"]
}


