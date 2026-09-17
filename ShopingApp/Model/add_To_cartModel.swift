
//
//  ProductModel.swift
//  ShopingApp
//
//  Created by Vijay on 01/09/26.
//
struct AddToCartResponse: Codable {
    let id: Int
    let products: [CartProduct]
    let total: Double?
    let discountedTotal: Double?
    let userId: Int?
    let totalProducts: Int?
    let totalQuantity: Int?
}

struct CartProduct: Codable {
    let id: Int
    let title: String
    let price: Double
    let quantity: Int
    let total: Double?
    let discountPercentage: Double? // 👈 Added ? so it doesn't crash if missing
    let discountedTotal: Double?    // 👈 Added ? so it doesn't crash if missing
    let thumbnail: String?
}
