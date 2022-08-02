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
    var details: (MediaType, Int) -> Effect<DetailModel, AppError>
    var collection: (Int) -> Effect<Movie.Collection, AppError>
    /// (tvID, seasonNumber)
    var season: (Int, Int) -> Effect<Season, AppError>
    var discover: (MediaType, [URL.DiscoverQueryItem]) -> Effect<PageResponses<Media>, AppError>
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
            let data = URLSession.shared
                .dataTaskPublisher(for: .details(
                    mediaType: mediaType, id: id,
                    appendToResponse: .images, .recommendations, .keywords, mediaType == .person ? .combined_credits : .credits
                ))
                .map { $0.data }
            switch mediaType {
            case .tv:
                return data
                    .decode(type: TVShow.self, decoder: defaultDecoder)
                    .tryEraseToEffect { .tv($0) }
            case .person:
                return data
                    .decode(type: Person.self, decoder: defaultDecoder)
                    .tryEraseToEffect { .person($0) }
            default:
                return data
                    .decode(type: Movie.self, decoder: defaultDecoder)
                    .tryEraseToEffect { .movie($0) }
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
        }
    )
    
    static let failing = Self(
        popular: { _ in .failing("MovieDBClient.popular") },
        trending: { _, _ in .failing("MovieDBClient.trending") },
        details: { _, _ in .failing("MovieDBClient.details") },
        collection: { _ in .failing("MovieDBClient.collection") },
        season: { _, _ in .failing("MovieDBClient.season") },
        discover: { _, _ in .failing("MovieDBClient.discover") }
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
                return Effect(error: .sample("Something Went Wrong"))
            case .movie:
                return Effect(value: .movie(mockMovies[0]))
            case .tv:
                return Effect(value: .tv(mockTVShows[0]))
            case .person:
                return Effect(value: .person(mockPeople[0]))
            }
        },
        collection: { id in
            Effect(value: mockCollection)
        },
        season: { _, _ in Effect(value: mockTVShows[0].seasons![0]) },
        discover: { _, _ in Effect(value: .init(results: mockMedias)) }
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
