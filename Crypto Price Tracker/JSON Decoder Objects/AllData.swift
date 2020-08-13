import Foundation
/*
Json parse template for the data of all coins
*/
struct AllData: Decodable{
    let data: [[String: String?]]
}
