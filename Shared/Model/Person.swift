//
//  Person.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation

struct Person: Codable, Equatable, Identifiable, DBResponses {
    var adult: Bool?
    var alsoKnownAs: [String]?
    var biography: String?
    var birthday: String?
    var deathday: String?
    var gender: Int?
    var homepage: String?
    var id: Int?
    var imdbId: String?
    var knownForDepartment: String?
    var name: String?
    var placeOfBirth: String?
    var popularity: Double?
    var profilePath: String?
    
    var success: Bool?
    var statusCode: Int?
    var statusMessage: String?
}
