//
//  Order_model.swift
//  ShopingApp
//
//  Created by Vijay on 19/09/26.
//
import Foundation

struct Order {
    
    let orderID: Int
    let productID: Int
    let productName: String
    let quantity: Int
    let price: Double
    let total: Double
    let paymentID: String
    let status: String
    let orderDate: String
    let thumbnail: String
}
