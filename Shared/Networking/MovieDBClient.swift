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
    
    var popular: (MediaType) -> Effect<[Media], AppError>
    var trending: (MediaType, TimeWindow) -> Effect<[Media], AppError>
    var details: @Sendable (MediaType, Int) async throws -> DetailModel
    var collection: (Int) -> Effect<Movie.Collection, AppError>
    /// (tvID, seasonNumber)
    var season: (Int, Int) -> Effect<Season, AppError>
    var discover: (MediaType, [URL.DiscoverQueryItem]) -> Effect<PageResponses<Media>, AppError>
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
            URLSession.shared.dataTaskPublisher(for: .popular(mediaType: mediaType))
                .map { $0.data }
                .decode(type: PageResponses<Media>.self, decoder: defaultDecoder)
                .tryEraseToEffect { $0.results ?? [] }
        },
        trending: { mediaType, timeWindow in
            URLSession.shared
                .dataTaskPublisher(for: .trending(mediaType: mediaType, timeWindow: timeWindow))
                .map { $0.data }
                .decode(type: PageResponses<Media>.self, decoder: defaultDecoder)
                .tryEraseToEffect { $0.results ?? [] }
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
            URLSession.shared
                .dataTaskPublisher(for: .collection(id: id))
                .map { $0.data }
                .decode(type: Movie.Collection.self, decoder: defaultDecoder)
                .tryEraseToEffect()
        },
        season: { tvID, seasonNumber in
            URLSession.shared
                .dataTaskPublisher(for: .season(tvID: tvID, seasonNumber: seasonNumber))
                .map { $0.data }
                .decode(type: Season.self, decoder: defaultDecoder)
                .tryEraseToEffect { $0 }
        },
        discover: { mediaType, queryItems in
            URLSession.shared
                .dataTaskPublisher(for: .discover(mediaType: mediaType, queryItems: queryItems))
                .map(\.data)
                .decode(type: PageResponses<Media>.self, decoder: defaultDecoder)
                .tryEraseToEffect()
        },
        search: { query, page in
            let (data, _) = try await URLSession.shared
                .data(from: .search(query: query, page: page))
            return try defaultDecoder.decodeResponse(PageResponses<Media>.self, from: data)
        }
    )
    
    static let previews = Self(
        popular: {
            Effect(value:  $0 == .movie ? mockMediaMovies : mockMediaTVShows)
        },
        trending: { _, _ in
            Effect(value: mockMedias)
        },
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
        collection: { id in
            Effect(value: mockCollection)
        },
        season: { _, _ in Effect(value: mockTVShows[0].seasons![0]) },
        discover: { _, _ in Effect(value: .init(results: mockMedias)) },
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
