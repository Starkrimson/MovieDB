//
//  PersonDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct PersonDetailView: View {
    let store: Store<PersonState, DetailAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                Text(viewStore.person.biography ?? "")
                    .padding(.horizontal)
                
                // MARK: - 图片
                ProfileImages(profiles: viewStore.images)
                
                // MARK: - 代表作
                KnownFor(knownFor: viewStore.knownFor)
                
                // MARK: - 参演
                Credits(credits: viewStore.combinedCredits)
            }
        }
    }
}

struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        IfLetStore(
            Store<DetailState, DetailAction>(
                initialState: .init(
                    media: mockMedias[2],
                    personState: .init(mockPeople[0])
                ),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .previews)
            ).scope(state: \.personState),
            then: PersonDetailView.init
        )
        .frame(minHeight: 950)
    }
}
