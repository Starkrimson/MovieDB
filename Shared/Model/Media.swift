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

struct PageResponses<Result>: Codable, Equatable, DBResponses, Hashable
where Result: Codable, Result: Equatable, Result: Hashable {

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
            profilePath: combinedCredit.profilePath,
            mediaType: combinedCredit.mediaType ?? .person,
            backdropPath: combinedCredit.backdropPath,
            id: combinedCredit.id,
            posterPath: combinedCredit.posterPath
        )
    }

    static func from(_ combinedCredit: Cast) -> Media {
        .init(
            name: combinedCredit.title ?? combinedCredit.name,
            profilePath: combinedCredit.profilePath,
            mediaType: combinedCredit.mediaType ?? .person,
            backdropPath: combinedCredit.backdropPath,
            id: combinedCredit.id,
            posterPath: combinedCredit.posterPath
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

    enum ImageType: String, CustomStringConvertible, CaseIterable, Identifiable {
        case videos, backdrops, posters, logos, stills

        var id: Self { self }

        var description: String {
            rawValue.uppercased().localized
        }
    }

    struct Images: Codable, Equatable, Hashable {
        /// movie / tv
        var backdrops: [Image]?
        var logos: [Image]?
        var posters: [Image]?

        /// person
        var profiles: [Image]?

        /// episode
        var stills: [Image]?

        var imageTypes: [ImageType] {
            var types: [ImageType] = []
            if backdrops?.isEmpty == false {
                types.append(.backdrops)
            }
            if posters?.isEmpty == false {
                types.append(.posters)
            }
//            if logos?.isEmpty == false {
//                types.append(.logos)
//            }
            if stills?.isEmpty == false {
                types.append(.stills)
            }
            return types
        }

        func images(of type: ImageType) -> [Image] {
            switch type {
            case .backdrops:
                return backdrops ?? []
            case .posters:
                return posters ?? []
            case .logos:
                return logos ?? []
            case .stills:
                return stills ?? []
            case .videos:
                return []
            }
        }
    }

    struct Image: Codable, Equatable, Identifiable, Hashable {
        var aspectRatio: Double?
        var filePath: String?
        var height: Int?
        var iso6391: String?
        var voteAverage: Double?
        var voteCount: Int?
        var width: Int?

        var id: String? { filePath }
    }

    struct Video: Codable, Equatable, Identifiable, Hashable {
//        var iso_639_1: String? // "en",
//        var iso_3166_1: String? // "US",
        var name: String? // "Q&A Featurette",
        var key: String? // "Gf4AXNthfVg",
        var site: String? // "YouTube",
        var size: Double? // 1080,
        var type: String? // "Featurette",
        var official: Bool? // true,
        var publishedAt: String? // "2022-10-15T19:00:11.000Z",
        var id: String? // "634e619e1089ba007d54910f"
    }
}

extension Media {
    struct Credits: Codable, Equatable, Hashable {
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
        var episodeCount: Int?

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
    }
}

extension Media.CombinedCredits {
    struct Credit: Equatable, Hashable, Identifiable {
        var year: String
        var title: String
        var character: String

        var mediaType: MediaType?
        var posterPath: String?
        var backdropPath: String?
        var id: Int?

        static func from(_ cast: Media.Cast) -> Credit {
            .init(
                year: String((cast.releaseDate ?? cast.firstAirDate ?? "").prefix(4)),
                title: cast.title ?? cast.name ?? "",
                character: cast.character.map({ "\("AS".localized) \($0)" }) ?? "",
                mediaType: cast.mediaType,
                posterPath: cast.posterPath,
                backdropPath: cast.backdropPath,
                id: cast.id
            )
        }

        static func from(_ crew: Media.Crew) -> Credit {
            .init(
                year: String((crew.releaseDate ?? crew.firstAirDate ?? "").prefix(4)),
                title: crew.title ?? crew.name ?? "",
                character: crew.job?.localized ?? "",
                mediaType: crew.mediaType,
                posterPath: crew.posterPath,
                backdropPath: crew.backdropPath,
                id: crew.id
            )
        }
    }
}
