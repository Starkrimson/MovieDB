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
    
    var popular: (MediaType) -> Effect<[MovieTV], AppError>
    var trending: (MediaType, TimeWindow) -> Effect<[MovieTV], AppError>
}

let defaultDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

extension MovieDBClient {
    static let live = Self(
        popular: { mediaType in
            URLSession.shared.dataTaskPublisher(for: .popular(mediaType: mediaType))
                .map { $0.data }
                .decode(type: PageResponses<MovieTV>.self, decoder: defaultDecoder)
                .tryEraseToEffect { $0.results ?? [] }
        },
        trending: { mediaType, timeWindow in
            URLSession.shared
                .dataTaskPublisher(for: .trending(mediaType: mediaType, timeWindow: timeWindow))
                .map { $0.data }
                .decode(type: PageResponses<MovieTV>.self, decoder: defaultDecoder)
                .tryEraseToEffect { $0.results ?? [] }
        }
    )
    
    static let failing = Self(
        popular: { _ in .failing("MovieDBClient.popular") },
        trending: { _, _ in .failing("MovieDBClient.trending") }
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
