//
//  MovieDBClient.swift
//  MovieDB
//
//  Created by allie on 11/7/2022.
//

import Foundation
import ComposableArchitecture
import Combine

struct MovieDBClient {
    
    var popular: @Sendable (MediaType) async throws -> [Media]
    var trending: @Sendable (MediaType, TimeWindow) async throws -> [Media]
    var details: @Sendable (MediaType, Int) async throws -> DetailModel
    var collection: @Sendable (Int) async throws -> Movie.Collection
    /// (tvID, seasonNumber)
    var season: @Sendable (Int, Int) async throws -> Season
    var discover: @Sendable (MediaType, [URL.DiscoverQueryItem]) async throws -> PageResponses<Media>
    /// (query, page)
    var search: @Sendable (String, Int) async throws -> PageResponses<Media>
}

let defaultDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
}()

extension MovieDBClient {
    static let live = Self(
        popular: { mediaType in
            let value = try await URLSession.shared
                .response(PageResponses<Media>.self, from: .popular(mediaType: mediaType))
            return value.results ?? []
        },
        trending: { mediaType, timeWindow in
            let value = try await URLSession.shared
                .response(PageResponses<Media>.self,
                          from: .trending(mediaType: mediaType, timeWindow: timeWindow))
            return value.results ?? []
        },
        details: { mediaType, id in
            do {
                try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                let (data, _) = try await URLSession.shared
                    .data(from: .details(
                        mediaType: mediaType, id: id,
                        appendToResponse: .images, .recommendations, .keywords, mediaType == .person ? .combined_credits : .credits
                    ))
                switch mediaType {
                case .tv:
                    let value = try defaultDecoder.decodeResponse(TVShow.self, from: data)
                    return .tv(value)
                case .person:
                    let value = try defaultDecoder.decodeResponse(Person.self, from: data)
                    return .person(value)
                default:
                    let value = try defaultDecoder.decodeResponse(Movie.self, from: data)
                    return .movie(value)
                }
            } catch {
                throw AppError.error(error)
            }
        },
        collection: { id in
            try await URLSession.shared
                .response(Movie.Collection.self, from: .collection(id: id))
        },
        season: { tvID, seasonNumber in
            try await URLSession.shared
                .response(Season.self,
                          from: .season(tvID: tvID, seasonNumber: seasonNumber))
        },
        discover: { mediaType, queryItems in
            try await URLSession.shared
                .response(PageResponses<Media>.self,
                          from: .discover(mediaType: mediaType, queryItems: queryItems))
        },
        search: { query, page in
            try await URLSession.shared
                .response(PageResponses<Media>.self, from: .search(query: query, page: page))
        }
    )
    
    static let previews = Self(
        popular: {
            $0 == .movie ? mockMediaMovies : mockMediaTVShows
        },
        trending: { _, _ in mockMedias },
        details: { mediaType, _ in
            switch mediaType {
            case .all:
                throw AppError.sample("Something Went Wrong")
            case .movie:
                return .movie(mockMovies[0])
            case .tv:
                return .tv(mockTVShows[0])
            case .person:
                return .person(mockPeople[0])
            }
        },
        collection: { id in mockCollection },
        season: { _, _ in mockTVShows[0].seasons![0] },
        discover: { _, _ in .init(results: mockMedias) },
        search: { _, _ in .init(results: mockMedias) }
    )
}

extension JSONDecoder {
    func decodeResponse<T>(_ type: T.Type, from data: Data) throws -> T where T: DBResponses, T: Decodable {
        let value = try decode(type, from: data)
        if value.success == false {
            throw AppError.sample(value.statusMessage)
        }
        return value
    }
}

extension URLSession {
    func response<T>(_ type: T.Type, from url: URL) async throws -> T where T: DBResponses, T: Decodable {
        do {
            let (data, _) = try await data(from: url)
            return try defaultDecoder.decodeResponse(type, from: data)
        } catch {
            throw AppError.error(error)
        }
    }
}
