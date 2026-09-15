//
//  carts_Model.swift
//  ShopingApp
//
//  Created by Vijay on 15/09/26.
//
import Foundation

// MARK: - Cart API Response

struct CartAPIResponse: Codable {
    let carts: [Cart]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Cart

struct Cart: Codable, Identifiable {
    let id: Int
    let products: [CartProduct]
    let total: Double
    let discountedTotal: Double
    let userId: Int
    let totalProducts: Int
    let totalQuantity: Int
}

// MARK: - Cart Product

struct CartProduct: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let quantity: Int
    let total: Double
    let discountPercentage: Double
    let discountedTotal: Double
    let thumbnail: String
}
