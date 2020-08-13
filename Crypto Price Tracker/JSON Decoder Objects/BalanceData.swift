import Foundation
/*
Json parse template for the balance data
*/

struct BalanceData: Decodable{
    let address: String
    let balance: Double
    
    var id: String?//the coin id that the address belongs to
    var addressNumber: Int?//the address number (1 or 2)
        
    /*
     Returns the balance of the address to the correct number of decimal places depnding on the coin
     */
    func getBalance() -> Double{
        var decimalPlaces: Int = 0
        if (id == "bitcoin"){
            decimalPlaces = 8
        }
        else if (id == "ethereum"){
            decimalPlaces = 18
        }
        return balance/pow(10.0, Double(decimalPlaces))
    }
}
