//
//  MovieTV.swift
//  MovieDB
//
//  Created by allie on 11/7/2022.
//

import Foundation

struct DBResponse<Result: Codable>: Codable {
    var page: Int?
    var totalResults: Int?
    var totalPages: Int?
    var results: [Result]?
}

struct MovieTV: Codable, Equatable, Identifiable {
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
    
    // 通用
    var backdropPath: String?
    var genreIds: [Int]?
    var id: Int?
    var originalLanguage: String?
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var voteAverage: Double?
    var voteCount: Int?
}
