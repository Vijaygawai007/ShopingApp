import Foundation
import Alamofire

class AddToCartViewModel {
    
    // 1. Singleton block (Correctly closed!)
    class var sharedInstance: AddToCartViewModel {
        struct Singleton {
            static let Instance = AddToCartViewModel()
        }
        return Singleton.Instance
    } // 👈 Notice this closing brace. It MUST be here!
    
    
    // 2. Add Product To Cart (Now safely outside the singleton block)
    func addToCart(
        productID: Int,
        userID: Int,
        quantity: Int = 1,
        completionHandler: @escaping (_ success: AddToCartResponse?, _ failure: String?) -> Void
    ) {
        
        // Ensure baseURL and Endpoints are defined elsewhere in your project
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
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { response in
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseObject = try decoder.decode(
                        AddToCartResponse.self,
                        from: data
                    )
                    
                    print("✅ API Success! Cart ID:", responseObject.id)
                    
                    // Return success to the View Controller
                    completionHandler(responseObject, nil)
                    
                } catch {
                    print("❌ Decoding Error:", error)
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, _): print("❌ Missing key:", key.stringValue)
                        case .typeMismatch(let type, _): print("❌ Type mismatch:", type)
                        case .valueNotFound(let type, _): print("❌ Value not found:", type)
                        case .dataCorrupted(let context): print("❌ Data corrupted:", context.debugDescription)
                        @unknown default: print("❌ Unknown decoding error")
                        }
                    }
                    completionHandler(nil, error.localizedDescription)
                }
                
            case .failure(let error):
                print("❌ API Error:", error)
                completionHandler(nil, error.localizedDescription)
            }
        }
    }
}
