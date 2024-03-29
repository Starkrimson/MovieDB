//
//  TVShow.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation

struct TVShow: Codable, Equatable, Identifiable, DBResponses, Hashable {
    var adult: Bool?
    var backdropPath: String?
    var createdBy: [Media.Crew]?
    var episodeRunTime: [Int]?
    var firstAirDate: Date?
    var genres: [Genre]?
    var homepage: String?
    var id: Int?
    var inProduction: Bool?
    var languages: [String]?
    var lastAirDate: Date?
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

    // append_to_response
    var images: Media.Images?
    var credits: Media.Credits?
    var recommendations: PageResponses<Media>?
    var keywords: PageResponses<Genre>?
    var videos: PageResponses<Media.Video>?
    var externalIds: ExternalIds?

    var success: Bool?
    var statusCode: Int?
    var statusMessage: String?
}

struct Season: Codable, Equatable, Identifiable, Hashable, DBResponses {
    var airDate: Date?
    var episodeCount: Int?
    var id: Int?
    var name: String?
    var overview: String?
    var posterPath: String?
    var seasonNumber: Int?

    var episodes: [Episode]?

    var credits: Media.Credits?

    var success: Bool?
    var statusCode: Int?
    var statusMessage: String?
}

struct Episode: Codable, Equatable, Identifiable, Hashable, DBResponses {
    var airDate: String?
    var episodeNumber: Int?
    var id: Int?
    var name: String?
    var overview: String?
    var productionCode: String?
    var runtime: Int?
    var seasonNumber: Int?
    var showId: Int?
    var stillPath: String?
    var voteAverage: Double?
    var voteCount: Int?

    var guestStars: [Media.Cast]?
    var crew: [Media.Crew]?

    var images: Media.Images?

    var success: Bool?
    var statusCode: Int?
    var statusMessage: String?
}

struct EpisodeToAir: Codable, Equatable, Identifiable, Hashable {
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

struct Network: Codable, Equatable, Identifiable, Hashable {
    var id: Int?
    var logoPath: String?
    var name: String?
    var originCountry: String?
}

extension TVShow {
    var externalLinks: ExternalLinks {
        .init(
            homepage: URL(string: homepage ?? ""),
            tmdb: id?.tmdbURL(mediaType: .tvShow),
            imdb: externalIds?.imdbId?.imdbURL(mediaType: .tvShow),
            facebook: externalIds?.facebookId?.facebookURL,
            twitter: externalIds?.twitterId?.twitterURL,
            instagram: externalIds?.instagramId?.instagramURL
        )
    }
}
