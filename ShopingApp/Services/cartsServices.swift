//
//  cartsServices.swift
//  ShopingApp
//
//  Created by Vijay on 15/09/26.
//

import Foundation
import Alamofire
import Kingfisher

class CartServices {
    
    class var sharedInstane: CartServices {
        struct Singleton {
            static let instance = CartServices()
        }
        return Singleton.instance
    }
    
    // MARK: - GET CART API SERVICES.
    func GetCartAPI<T: Codable, U: Encodable>(_ endpoint: String,parameters: U,result: T.Type,CompletionHandler: @escaping (_ success: T?,_ failure: String?) -> Void) {
        
        let urlString = "\(baseURL)/\(endpoint)"
        
        AF.request(urlString,method: .get,parameters: parameters,encoder: JSONParameterEncoder.default).responseData { response in
            
            switch response.result {
                
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseObject = try decoder.decode(T.self, from: data)
                    
                    CompletionHandler(responseObject, nil)
                    
                } catch {
                    print("Decoding Error:", error)
                    CompletionHandler(nil, error.localizedDescription)
                }
                
            case .failure(let error):
                
                print("API Error:", error)
                CompletionHandler(nil, error.localizedDescription)
            }
        }
    }
}
