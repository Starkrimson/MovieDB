//
//  TVShow.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation

struct TVShow: Codable, Equatable, Identifiable, DBResponses {
    var adult: Bool?
    var backdropPath: String?
    var createdBy: [CreatedBy]?
    var episodeRunTime: [Int]?
    var firstAirDate: String?
    var genres: [Genre]?
    var homepage: String?
    var id: Int?
    var inProduction: Bool?
    var languages: [String]?
    var lastAirDate: String?
    var lastEpisodeToAir: EpisodeToAir?
    var name: String?
    var networks: [Network]?
    var nextEpisodeToAir: EpisodeToAir?
    var numberOfEpisodes: Int?
    var numberOfSeasons: Int?
    var originCountry: [String]?
    var originalLanguage: String?
    var originalName: String?
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var productionCompanies: [ProductionCompany]?
    var productionCountries: [ProductionCountry]?
    var seasons: [Season]?
    var spokenLanguages: [SpokenLanguage]?
    var status: String?
    var tagline: String?
    var type: String?
    var voteAverage: Double?
    var voteCount: Int?
    
    var success: Bool?
    var statusCode: Int?
    var statusMessage: String?
}

struct CreatedBy: Codable, Equatable, Identifiable {
    var creditId: String?
    var gender: Int?
    var id: Int?
    var name: String?
    var profilePath: String?
}

struct Season: Codable, Equatable, Identifiable {
    var airDate: String?
    var episodeCount: Int?
    var id: Int?
    var name: String?
    var overview: String?
    var posterPath: String?
    var seasonNumber: Int?
}

struct EpisodeToAir: Codable, Equatable, Identifiable {
    var airDate: String?
    var episodeNumber: Int?
    var id: Int?
    var name: String?
    var overview: String?
    var productionCode: String?
    var runtime: Int?
    var seasonNumber: Int?
    var stillPath: String?
    var voteAverage: Double?
    var voteCount: Int?
}

struct Network: Codable, Equatable, Identifiable {
    var id: Int?
    var logoPath: String?
    var name: String?
    var originCountry: String?
}
