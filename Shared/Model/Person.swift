//
//  Person.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation

struct Person: Codable, Equatable, Identifiable, DBResponses, Hashable {
    var adult: Bool?
    var alsoKnownAs: [String]?
    var biography: String?
    var birthday: String?
    var deathday: String?
    var gender: Gender?
    var homepage: String?
    var id: Int?
    var imdbId: String?
    var knownForDepartment: String?
    var name: String?
    var placeOfBirth: String?
    var popularity: Double?
    var profilePath: String?

    // append_to_response
    var images: Media.Images?
    var combinedCredits: Media.Credits?

    var success: Bool?
    var statusCode: Int?
    var statusMessage: String?
}

enum Gender: Int, Codable, CustomStringConvertible {
    case unknown = -1
    case female = 1, male = 2

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = Self(rawValue: value) ?? .unknown
    }

    var description: String {
        switch self {
        case .unknown:
            return ""
        case .male:
            return "MALE".localized
        case .female:
            return "FEMALE".localized
        }
    }
}
