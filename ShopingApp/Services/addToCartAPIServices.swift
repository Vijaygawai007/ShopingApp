//
//  ProductModel.swift
//  ShopingApp
//
//  Created by Vijay on 01/09/26.
//
import Foundation
import Alamofire
import Kingfisher

class addToCartAPIServices {
    
    class var sharedInstane: addToCartAPIServices {
        struct Singleton {
            static let instance = addToCartAPIServices()
        }
        return Singleton.instance
    }
    
    // MARK: - POST API
    
    func AddToCartAPI<T: Codable, U: Encodable>(_ endpoint: String,parameters: U,result: T.Type,CompletionHandler: @escaping (_ success: T?,_ failure: String?) -> Void) {
        
        let urlString = "\(baseURL)/\(endpoint)"
        
        AF.request(urlString,method: .post,parameters: parameters,encoder: JSONParameterEncoder.default).responseData { response in
            
            switch response.result {
            
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseObject =
                    try decoder.decode(T.self, from: data)
                    
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
