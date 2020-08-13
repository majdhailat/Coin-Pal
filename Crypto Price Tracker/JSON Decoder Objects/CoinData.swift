import Foundation
/*
Json parse template for the coin data
*/

struct CoinData: Decodable{
    let data:[String: String?]//dictionary of all the data
    //keys to the dictionary
    static let idKey: String = "id"
    static let priceKey: String = "priceUsd"
    static let change24HKey: String = "changePercent24Hr"
    static let mareketCapKey: String = "marketCapUsd"
}
