//
//  PersonDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct PersonDetailView: View {
    let store: Store<PersonState, DetailReducer.Action>

    var body: some View {
        WithViewStore(store) { $0 } content: { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                Text(viewStore.person.biography ?? "")
                    .padding(.horizontal)

                // MARK: - 图片
                ProfileImages(profiles: viewStore.images)
                    .padding(.top)

                if !viewStore.knownFor.isEmpty {
                    // MARK: - 代表作
                    KnownFor(knownFor: viewStore.knownFor)
                }

                // MARK: - 参演
                Credits(credits: viewStore.combinedCredits)

                Color.clear
            }
        }
    }
}

#if DEBUG
struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        IfLetStore(
            StoreOf<DetailReducer>(
                initialState: .init(
                    media: mockMedias[2],
                    detail: .person(.init(mockPeople[0]))
                ),
                reducer: { DetailReducer() }
            )
            .scope(state: \.detail, action: { $0 }),
            then: { detailStore in
                SwitchStore(detailStore) { _ in
                    CaseLet(
                        state: /DetailReducer.DetailState.person,
                        then: PersonDetailView.init
                    )
                }
            }
        )
        .frame(minHeight: 1250)
    }
}
#endif
