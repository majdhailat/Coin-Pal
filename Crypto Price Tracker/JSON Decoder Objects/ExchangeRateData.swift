import Foundation
/*
Json parse template for the exchange rate data
Contains the tickers for all the exchange rates
*/
struct ExchangeRateData: Decodable{
    let rates:[String: Double]
    let base: String
    
    static let fiatCurrencies = ["AUD", "BGN", "BRL", "CAD", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "ISK", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB","CHF", "TRY", "USD", "ZAR"]
}
