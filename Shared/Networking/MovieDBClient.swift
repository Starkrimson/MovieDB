//
//  MovieDBClient.swift
//  MovieDB
//
//  Created by allie on 11/7/2022.
//

import Foundation
import ComposableArchitecture

struct MovieDBClient {
    
    var popular: (Kind) -> Effect<[MovieTV], AppError>
    
    enum Kind: String {
        case movie, tv
    }
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
        popular: { kind in
            let url = URL(string: "\(baseURL)/\(kind.rawValue)/popular?api_key=\(apiKey)&language=zh&page=1")!
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: DBResponse<MovieTV>.self, decoder: defaultDecoder)
                .map { $0.results ?? [] }
                .mapError { AppError.networkingFailed($0) }
                .eraseToEffect()
        }
    )
    
    static let failing = Self(
        popular: { _ in .failing("MovieDBClient.popular") }
    )
}
