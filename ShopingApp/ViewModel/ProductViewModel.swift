//
//  ProductViewModel.swift
//  ShopingApp
//
//  Created by Vijay on 01/09/26.
//

import Foundation
import Alamofire
import Kingfisher

class ProductViewModel:NSObject{
    class var sharedInstance : ProductViewModel{
        struct Singleton {
            static let Instance = ProductViewModel()
        }
        return Singleton.Instance
    }
    
    func ProductAPI( CompletionHandler: @escaping (_ success: ProductResponse?,_ failure: String?) -> Void ) {
        
        let urlRequest  = URL(string: "\(baseURL)\(Endpoints().product)")
        
        AF.request(urlRequest!,method: .get, encoding: JSONEncoding.default).responseJSON { [weak self] response in
            guard let data = response.data else {
                CompletionHandler(nil, ErrorReason().errorMessage)
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(ProductResponse.self, from: data)
                CompletionHandler(responseObject,nil)
                print(responseObject)
            }catch let error {
                print(error.localizedDescription)
                CompletionHandler(nil, ErrorReason().errorMessage)
            }
        }
    }
}
