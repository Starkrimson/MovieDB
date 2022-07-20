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

/// https://developers.themoviedb.org/3/getting-started/append-to-response
enum AppendToResponse: String {
    case images, videos, credits, similar, recommendations, keywords
}
