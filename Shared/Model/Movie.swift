//
//  Movie.swift
//  MovieDB
//
//  Created by allie on 13/7/2022.
//

import Foundation

enum DetailModel: Equatable {
    case movie(Movie)
    case tv(TVShow)
    case person(Person)
    
    var mediaType: MediaType {
        switch self {
        case .movie:
            return .movie
        case .tv:
            return .tv
        case .person:
            return .person
        }
    }
}

struct Movie: Codable, Equatable, Identifiable, DBResponses {
    var adult: Bool?
    var backdropPath: Int?
    var belongsToCollection: BelongsToCollection?
    var budget: Int?
    var genres: [Genre]?
    var homepage: String?
    var id: Int?
    var imdbId: String?
    var originalLanguage: String?
    var originalTitle: String?
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var productionCompanies: [ProductionCompany]?
    var productionCountries: [ProductionCountry]?
    var releaseDate: Date?
    var revenue: Int?
    var runtime: Int?
    var spokenLanguages: [SpokenLanguage]?
    /// Allowed Values: Rumored, Planned, In Production, Post Production, Released, Canceled
    var status: Status?
    var tagline: String?
    var title: String?
    var video: Bool?
    var voteAverage: Double?
    var voteCount: Int?
    
    // append_to_response
    var images: Media.Images?
    var credits: Media.Credits?
    var recommendations: PageResponses<Media>?
    var keywords: Keywords?

    var success: Bool?
    var statusCode: Int?
    var statusMessage: String?
    
    enum Status: String, Codable {
        case rumored = "Rumored"
        case planned = "Planned"
        case inProduction = "In Production"
        case postProduction = "Post Production"
        case released = "Released"
        case canceled = "Canceled"
        
        init(from decoder: Decoder) throws {
            let value = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: value) ?? .rumored
        }
    }
}

struct SpokenLanguage: Codable, Equatable, Identifiable {
    var englishName: String?
    var iso6391: String?
    var name: String?
    
    var id: String? { iso6391 }
}

struct ProductionCountry: Codable, Equatable, Identifiable {
    var iso31661: String?
    var name: String?
    
    var id: String? { iso31661 }
}

struct ProductionCompany: Codable, Equatable, Identifiable {
    var id: Int?
    var logoPath: String?
    var name: String?
    var originCountry: String?
}

struct Genre: Codable, Equatable, Identifiable {
    var id: Int?
    var name: String?
}

struct BelongsToCollection: Codable, Equatable, Identifiable, Hashable {
    var backdropPath: String?
    var id: Int?
    var name: String?
    var posterPath: String?
}

struct Keywords: Codable, Equatable {
    var keywords: [Genre]?
}

extension Movie {
    
    struct Collection: Codable, Equatable, Identifiable, DBResponses {
        var backdropPath: String?
        var id: Int?
        var name: String?
        var overview: String?
        var parts: [Media]?
        var posterPath: String?
        
        var success: Bool?
        var statusCode: Int?
        var statusMessage: String?
    }
}
