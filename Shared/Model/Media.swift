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
    
    static func from(_ combinedCredit: Crew) -> Media {
        .init(
            name: combinedCredit.title ?? combinedCredit.name,
            mediaType: combinedCredit.mediaType ?? .person,
            backdropPath: combinedCredit.backdropPath,
            id: combinedCredit.id,
            posterPath: combinedCredit.posterPath ?? combinedCredit.profilePath
        )
    }
    
    static func from(_ combinedCredit: Cast) -> Media {
        .init(
            name: combinedCredit.title ?? combinedCredit.name,
            mediaType: combinedCredit.mediaType ?? .person,
            backdropPath: combinedCredit.backdropPath,
            id: combinedCredit.id,
            posterPath: combinedCredit.posterPath ?? combinedCredit.profilePath
        )
    }
    
    static func from(_ combinedCredit: CombinedCredits.Credit) -> Media {
        .init(
            name: combinedCredit.title,
            mediaType: combinedCredit.mediaType ?? .person,
            backdropPath: combinedCredit.backdropPath,
            id: combinedCredit.id,
            posterPath: combinedCredit.posterPath
        )
    }
}

extension Media {
    
    enum ImageType: CustomStringConvertible, CaseIterable, Identifiable {
        case backdrop, poster
        
        var id: Self { self }
        
        var description: String {
            switch self {
            case .poster:
                return "海报"
            case .backdrop:
                return "剧照"
            }
        }
    }
    
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
    
    struct Cast: Codable, Equatable, Identifiable, Hashable, Comparable {
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
        
        // Combined Credits
        var mediaType: MediaType?

        var title: String?
        var originalTitle: String?
        var posterPath: String?
        var backdropPath: String?
        var releaseDate: String?
                
        var firstAirDate: String?
        
        static func < (lhs: Media.Cast, rhs: Media.Cast) -> Bool {
            (lhs.releaseDate ?? lhs.firstAirDate ?? "")
            < (rhs.releaseDate ?? rhs.firstAirDate ?? "")
        }
    }
    
    struct Crew: Codable, Equatable, Identifiable, Hashable, Comparable {
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
        
        // Combined Credits
        var mediaType: MediaType?

        var title: String?
        var originalTitle: String?
        var posterPath: String?
        var backdropPath: String?
        var releaseDate: String?
                
        var firstAirDate: String?
        
        static func < (lhs: Media.Crew, rhs: Media.Crew) -> Bool {
            (lhs.releaseDate ?? lhs.firstAirDate ?? "")
            < (rhs.releaseDate ?? rhs.firstAirDate ?? "")
        }
    }
    
    struct CombinedCredits: Equatable, Hashable, Identifiable {
        var department: String
        var credits: [Credit]
        
        var id: String { department }
        
        struct Credit: Equatable, Hashable, Identifiable {
            var year: String
            var title: String
            var character: String
            
            var mediaType: MediaType?
            var posterPath: String?
            var backdropPath: String?
            var id: Int?
        }
    }
}
