//
//  ImageGridReducer.swift
//  MovieDB
//
//  Created by allie on 20/11/2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ImageGridReducer {

    struct State: Equatable, Hashable {
        let images: Media.Images
        var videos: [Media.Video] = []

        @BindingState var selectedImageType: Media.ImageType = .backdrops
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { _, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
}
