//
//  MovieDBClient.swift
//  MovieDB
//
//  Created by allie on 11/7/2022.
//

import Foundation
import ComposableArchitecture

struct MovieDBClient {
    
    var popular: (MediaType) -> Effect<[MovieTV], AppError>
    var trending: () -> Effect<[MovieTV], AppError>
}

let baseURL = "https://api.themoviedb.org/3"
let apiKey = ""
let defaultDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

extension MovieDBClient {
    static let live = Self(
        popular: { mediaType in
            let url = URL(string: "\(baseURL)/\(mediaType.rawValue)/popular?api_key=\(apiKey)&language=zh&page=1")!
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: DBResponse<MovieTV>.self, decoder: defaultDecoder)
                .map { $0.results ?? [] }
                .mapError { AppError.networkingFailed($0) }
                .eraseToEffect()
        },
        trending: {
            .failing("")
        }
    )
    
    static let failing = Self(
        popular: { _ in .failing("MovieDBClient.popular") },
        trending: { .failing("MovieDBClient.trending") }
    )
}
