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
    
    var popular: @Sendable (MediaType, _ page: Int) async throws -> PageResponses<Media>
    var trending: @Sendable (MediaType, TimeWindow) async throws -> [Media]
    var details: @Sendable (MediaType, Int) async throws -> DetailModel
    var collection: @Sendable (Int) async throws -> Movie.Collection
    /// (tvID, seasonNumber)
    var season: @Sendable (Int, Int) async throws -> Season
    var episode: @Sendable (_ tvID: Int, _ seasonNumber: Int, _ episodeNumber: Int)  async throws -> Episode
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

extension DependencyValues {
    var dbClient: MovieDBClient {
        get { self[MovieDBClient.self] }
        set { self[MovieDBClient.self] = newValue }
    }
}

extension MovieDBClient: DependencyKey {
    static var liveValue: MovieDBClient = Self(
        popular: { mediaType, page in
            var value = try await URLSession.shared
                .response(PageResponses<Media>.self, from: .popular(mediaType: mediaType, page: page))
            value.results = value.results?.map {
                var item = $0
                item.mediaType = mediaType
                return item
            }
            return value
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
        episode: { tvID, seasonNumber, episodeNumber in
            try await URLSession.shared
                .response(
                    Episode.self,
                    from: .episode(
                        tvID: tvID,
                        seasonNumber: seasonNumber,
                        episodeNumber: episodeNumber,
                        appendToResponse: .images
                    )
                )
        },
        discover: { mediaType, queryItems in
            var value = try await URLSession.shared
                .response(PageResponses<Media>.self,
                          from: .discover(mediaType: mediaType, queryItems: queryItems))
            value.results = value.results?.map {
                var item = $0
                item.mediaType = mediaType
                return item
            }
            return value
        },
        search: { query, page in
            try await URLSession.shared
                .response(PageResponses<Media>.self, from: .search(query: query, page: page))
        }
    )
    
    static var previewValue: MovieDBClient = Self(
        popular: { type, _ in
            .init(results: type == .movie ? mockMediaMovies : mockMediaTVShows)
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
        episode: { _, _, _ in mockTVShows[0].seasons![0].episodes![0] },
        discover: { _, _ in .init(results: mockMedias) },
        search: { _, _ in .init(results: mockMedias) }
    )
    
    static var testValue: MovieDBClient = previewValue
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
