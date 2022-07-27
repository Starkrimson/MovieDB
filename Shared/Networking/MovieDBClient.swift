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
                .tryEraseToEffect {
                    $0.results?.map {
                        var media = $0
                        media.mediaType = mediaType
                        return media
                    } ?? []
                }
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
                .tryEraseToEffect {
                    var collection = $0
                    collection.parts = collection.parts?.map {
                        var media = $0
                        media.mediaType = .movie
                        return media
                    }
                    return collection
                }
        }
    )
    
    static let failing = Self(
        popular: { _ in .failing("MovieDBClient.popular") },
        trending: { _, _ in .failing("MovieDBClient.trending") },
        details: { _, _ in .failing("MovieDBClient.details") },
        collection: { _ in .failing("MovieDBClient.collection") }
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
        }
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
}
