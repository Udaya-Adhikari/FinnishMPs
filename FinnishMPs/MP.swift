
//
//  MP.swift
//  FinnishMPs
//
//  Created by Kapil
//  Student ID: 2420250
//

import Foundation

struct MP: Codable, Identifiable {
    let personNumber: Int
    let seatNumber: Int
    let first: String
    let last: String
    let party: String
    let minister: Bool
    let picture: String?
    let twitter: String?
    let bornYear: Int
    let constituency: String

    var id: Int {
        personNumber
    }

    var fullName: String {
        "\(first) \(last)"
    }
}

