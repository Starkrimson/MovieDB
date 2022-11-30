//
//  MovieDB.swift
//  MovieDB
//
//  Created by allie on 13/7/2022.
//

import Foundation

enum MediaType: String, Codable, CaseIterable, Identifiable {
    var id: Self { self }

    case all, movie
    case tvShow = "tv"
    case person

    var localizedDescription: String {
        switch self {
        case .tvShow:
            return "TV SHOWS".localized
        case .movie:
            return "MOVIES".localized
        case .person:
            return "PEOPLE".localized
        case .all:
            return "ALL".localized
        }
    }

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
    case combinedCredits = "combined_credits"
}
