//
//  Profile_Model.swift
//  ShopingApp
//
//  Created by Vijay on 30/09/26.
//

import Foundation

struct Profilee : Codable {
    let id: UUID
    let fullName: String
    let phone: String
    let email: String
    let address: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case phone
        case email
        case address
        case profileImage = "profile_image"
    }
}
