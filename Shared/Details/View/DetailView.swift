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
    let store: Store<DetailState, DetailAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button(viewStore.movie?.title ?? "none") {
                    viewStore.send(.fetchDetails(mediaType: .movie))
                }
                KFImage(URL(string: viewStore.movie?.posterPath?.imagePath ?? ""))
                    .resizable()
                    .frame(width: 150, height: 225)
                    .cornerRadius(10)
            }
            .navigationTitle(viewStore.media.displayName)
            .onAppear {
                viewStore.send(.fetchDetails(mediaType: .movie))
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            store: .init(
                initialState: .init(media: mockMedias[0]),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .failing)
            )
        )
    }
}
