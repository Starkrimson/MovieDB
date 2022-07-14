//
//  DetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Kingfisher

struct DetailView: View {
    let media: Media
    let store: Store<DetailState, DetailAction>
    
    init(media: Media) {
        self.media = media
        store = .init(
            initialState: .init(media: media),
            reducer: detailReducer,
            environment: .init(mainQueue: .main, dbClient: .live)
        )
    }
    
    var body: some View {
        switch media.mediaType  {
        case .movie:
            MovieDetailView(store: store)

        case .tv:
            TVDetailView(store: store)
            
        case .person:
            PersonDetailView(store: store)
            
        default:
            EmptyView()
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(media: mockMedias[0])
    }
}
