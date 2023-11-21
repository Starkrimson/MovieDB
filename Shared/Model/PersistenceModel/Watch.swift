//
//  Watch.swift
//  MovieDB
//
//  Created by allie on 21/11/2023.
//
//

import Foundation
import SwiftData

@Model class Watch {
    var backdropPath: String?
    var dateAdded: Date?
    var id: Int32? = 0
    var mediaType: String?
    var overview: String?
    var posterPath: String?
    var releaseDate: String?
    var title: String?

    public init() { }
}
