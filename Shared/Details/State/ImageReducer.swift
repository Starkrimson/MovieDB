//
//  ImageReducer.swift
//  MovieDB
//
//  Created by allie on 20/11/2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ImageReducer {

    struct State: Equatable, Hashable {
        var image: Media.Image

        var originURL: URL {
            guard let path = image.filePath?.imagePath(.original),
                  let url = URL(string: path) else {
                return URL(filePath: "/null")
            }
            return url
        }

        var ratio: Double {
            guard let width = image.width, let height = image.height else {
                return 1
            }
            return Double(width) / Double(height)
        }
    }

    enum Action: Equatable {

    }

    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
