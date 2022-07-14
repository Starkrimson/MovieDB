//
//  TVDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct TVDetailView: View {
    let store: Store<DetailState, DetailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button(viewStore.tv?.name ?? "none") {
                    viewStore.send(.fetchDetails(mediaType: .tv))
                }
                KFImage(URL(string: viewStore.tv?.posterPath?.imagePath ?? ""))
                    .resizable()
                    .frame(width: 150, height: 225)
                    .cornerRadius(10)
            }
            .navigationTitle(viewStore.media.displayName)
            .onAppear {
                viewStore.send(.fetchDetails(mediaType: .tv))
            }
        }
    }
}

struct TVDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TVDetailView(
            store: .init(
                initialState: .init(media: mockMedias[0]),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .failing)
            )
        )
    }
}
