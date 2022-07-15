//
//  PersonDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct PersonDetailView: View {
    let store: Store<DetailState, DetailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button(viewStore.person?.name ?? "none") {
                    viewStore.send(.fetchDetails(mediaType: .person))
                }
                KFImage(URL(string: viewStore.person?.profilePath?.imagePath() ?? ""))
                    .resizable()
                    .frame(width: 150, height: 225)
                    .cornerRadius(10)
            }
            .navigationTitle(viewStore.media.displayName)
            .onAppear {
                viewStore.send(.fetchDetails(mediaType: .person))
            }
        }
    }
}

struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailView(
            store: .init(
                initialState: .init(media: mockMedias[0]),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .failing)
            )
        )
    }
}
