//
//  sopabaseModel.swift
//  ShopingApp
//
//  Created by Vijay on 25/09/26.
//


//
//  Profile.swift
//  ShopingApp
//
//  Created by Vijay on 25/09/26.
//
import Foundation

struct Profile: Codable {

    let id: UUID
    var fullName: String
    var email: String
    var phone: String
    var address: String?
    var profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case phone
        case address
        case profileImage = "profile_image"
    }
}
