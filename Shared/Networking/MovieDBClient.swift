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
            let (data, _) = try await URLSession.shared
                .data(from: .popular(mediaType: mediaType))
            let value = try defaultDecoder.decodeResponse(PageResponses<Media>.self, from: data)
            return value.results ?? []
        },
        trending: { mediaType, timeWindow in
            let (data, _) = try await URLSession.shared
                .data(from: .trending(mediaType: mediaType, timeWindow: timeWindow))
            let value = try defaultDecoder.decodeResponse(PageResponses<Media>.self, from: data)
            return value.results ?? []
        },
        details: { mediaType, id in
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
        },
        collection: { id in
            let (data, _) = try await URLSession.shared
                .data(from: .collection(id: id))
            return try defaultDecoder.decodeResponse(Movie.Collection.self, from: data)
        },
        season: { tvID, seasonNumber in
            let (data, _) = try await URLSession.shared
                .data(from: .season(tvID: tvID, seasonNumber: seasonNumber))
            return try defaultDecoder.decodeResponse(Season.self, from: data)
        },
        discover: { mediaType, queryItems in
            let (data, _) = try await URLSession.shared
                .data(from: .discover(mediaType: mediaType, queryItems: queryItems))
            return try defaultDecoder.decodeResponse(PageResponses<Media>.self, from: data)
        },
        search: { query, page in
            let (data, _) = try await URLSession.shared
                .data(from: .search(query: query, page: page))
            return try defaultDecoder.decodeResponse(PageResponses<Media>.self, from: data)
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

extension Publisher {
    
    /// tryMap 返回数据，如果 success == false 抛出错误
    func tryEraseToEffect<T>(_ transform: @escaping (Self.Output) -> T)
    -> Effect<T, AppError> where Output: DBResponses {
        tryMap { output in
            if output.success == false {
                throw AppError.sample(output.statusMessage)
            }
            return transform(output)
        }
        .mapError { error in
            if error is AppError  {
                return error as! AppError
            }
            return AppError.networkingFailed(error)
        }
        .eraseToEffect()
    }
    
    func tryEraseToEffect<T>() -> Effect<T, AppError> where Output: DBResponses {
        tryEraseToEffect { $0 as! T }
    }
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
