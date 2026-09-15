//
//  add_To_CartView_Model.swift
//  ShopingApp
//
//  Created by Vijay on 13/09/26.
//

import Foundation
import Alamofire

class addToCartViewModel {
    
    class var sharedInstance: addToCartViewModel {
        struct Singleton {
            static let Instance = addToCartViewModel()
        }
        return Singleton.Instance
    }
    
    // MARK: - Add Product To Cart
    
    func addToCart(productID: Int,userID: Int,quantity: Int = 1,completionHandler: @escaping (_ success: AddToCartResponse?,_ failure: String?) -> Void) {
        
        let urlString = "\(baseURL)\(Endpoints().add_To_Cart)"
        
        let parameters: [String: Any] = [
            "userId": userID,
            "products": [
                [
                    "id": productID,
                    "quantity": quantity
                ]
            ]
        ]
        
        AF.request(
            urlString,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        .responseData { response in
            
            switch response.result {
                
            case .success(let data):
                
                do {
                    
                    let decoder = JSONDecoder()
                    
                    let responseObject =
                    try decoder.decode(
                        AddToCartResponse.self,
                        from: data
                    )
                    
                    print("Product added to cart")
                    print("Cart ID:", responseObject.id)
                    
                    completionHandler(responseObject, nil)
                    
                } catch {
                    
                    print("Decoding Error:", error)
                    
                    completionHandler(
                        nil,
                        error.localizedDescription
                    )
                }
                
            case .failure(let error):
                
                print("API Error:", error)
                
                completionHandler(
                    nil,
                    error.localizedDescription
                )
            }
        }
    }
}
