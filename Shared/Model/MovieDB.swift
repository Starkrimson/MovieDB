//
//  MovieDB.swift
//  MovieDB
//
//  Created by allie on 13/7/2022.
//

import Foundation

enum MediaType: String, Codable {
    case all, movie, tv, person
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = Self(rawValue: value) ?? .all
    }
}

enum TimeWindow: String {
    case day, week
}
