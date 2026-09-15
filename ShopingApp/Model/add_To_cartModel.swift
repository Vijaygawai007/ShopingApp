
//
//  ProductModel.swift
//  ShopingApp
//
//  Created by Vijay on 01/09/26.
//

import Foundation
import UIKit

//MARK: Reqiest Model
struct AddToCartRequest: Codable {
    let userId: Int
    let products: [AddToCartProduct]
}

struct AddToCartProduct: Codable {
    let id: Int
    let quantity: Int
}

//MARK: Response model
struct AddToCartResponse: Codable {
    let id: Int
    let userId: Int
    let products: [CartProduct]
    let total: Double
    let discountedTotal: Double
    let totalProducts: Int
    let totalQuantity: Int
}
//MARK: CART PRODUCTS
struct addCartProduct: Codable {
    let id: Int
    let title: String
    let price: Double
    let quantity: Int
    let total: Double
    let discountPercentage: Double
    let discountedTotal: Double?
    let thumbnail: String
}
