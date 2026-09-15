//
//  ProductAPIService.swift
//  ShopingApp
//
//  Created by Vijay on 01/09/26.
//

import Foundation
import Alamofire
import Kingfisher

class ProductAPIService {
    class var sharedInstane: ProductAPIService {
        struct Singleton {
            static let instance = ProductAPIService()
        }
        return Singleton.instance
    }
    
    //MARK: GET API REQUEST
    func ProductAPI_Service<T: Codable>(_ endpoint: String, result: T.Type, CompletionHandler: @escaping(_ success: T?, _ failure: String?) -> Void) {
        let urlString = URL(string: "\(baseURL),\(endpoint)")
        
        AF.request(urlString!, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { respose in
            
            guard let data = respose.data else{
                CompletionHandler(nil,ErrorReason().errorMessage)
                return
            }
            do{
                let Decoder = JSONDecoder()
                let data2 = try Decoder.decode(T.self, from: data)
                CompletionHandler(data2,nil)
                
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
