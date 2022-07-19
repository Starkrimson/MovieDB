//
//  MovieTV.swift
//  MovieDB
//
//  Created by allie on 11/7/2022.
//

import Foundation

protocol DBResponses {
    var success: Bool? { get }
    var statusCode: Int? { get }
    var statusMessage: String? { get }
}

struct PageResponses<Result>: Codable, Equatable, DBResponses
where Result: Codable, Result: Equatable {
    
    var page: Int?
    var totalResults: Int?
    var totalPages: Int?
    var results: [Result]?
    
    var success: Bool?
    var statusCode: Int?
    var statusMessage: String?
}

struct Media: Codable, Equatable, Identifiable, Hashable {
    // movie
    var adult: Bool?
    var title: String?
    var originalTitle: String?
    var releaseDate: String?
    var video: Bool?
    
    // tv
    var firstAirDate: String?
    var name: String?
    var originalName: String?
    var originCountry: [String]?
    
    // person
    var gender: Int?
    var knownForDepartment: String?
    var profilePath: String?
    var knownFor: [Media]?
    
    // 通用
    var mediaType: MediaType?
    
    var backdropPath: String?
    var genreIds: [Int]?
    var id: Int?
    var originalLanguage: String?
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var voteAverage: Double?
    var voteCount: Int?
    
    var displayName: String {
        title ?? name ?? ""
    }
    
    var displayPosterPath: String {
        "\(posterPath ?? profilePath ?? "")".imagePath()
    }
}

extension Media {
    
    struct Images: Codable, Equatable {
        /// movie / tv
        var backdrops: [Image]?
        var logos: [Image]?
        var posters: [Image]?
        
        /// person
        var profiles: [Image]?
    }
    
    struct Image: Codable, Equatable, Identifiable {
        var aspectRatio: Double?
        var filePath: String?
        var height: Int?
        var iso6391: String?
        var voteAverage: Double?
        var voteCount: Int?
        var width: Int?
        
        var id: String? { filePath }
    }
}

extension Media { 
    struct Credits: Codable, Equatable {
        var cast: [Cast]?
        var crew: [Crew]?
    }
    
    struct Cast: Codable, Equatable, Identifiable {
        var adult: Bool?
        var castId: Int?
        var character: String?
        var creditId: String?
        var gender: Int?
        var id: Int?
        var knownForDepartment: String?
        var name: String?
        var order: Int?
        var originalName: String?
        var popularity: Double?
        var profilePath: String?
    }
    
    struct Crew: Codable, Equatable, Identifiable {
        var adult: Bool?
        var creditId: String?
        var department: String?
        var gender: Int?
        var id: Int?
        var job: String?
        var knownForDepartment: String?
        var name: String?
        var originalName: String?
        var popularity: Double?
        var profilePath: String?
    }
}
