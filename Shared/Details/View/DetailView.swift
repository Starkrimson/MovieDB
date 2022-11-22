//
//  DetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct DetailView: View {
    let store: StoreOf<DetailReducer>

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            ScrollView {
                Header(state: viewStore.state)

                switch viewStore.status {
                case .loading: ProgressView()
                case .error(let error):
                    ErrorTips(error: error)
                case .normal:
                    IfLetStore(store.scope(state: \.detail)) { letStore in
                        SwitchStore(letStore) {
                            CaseLet(
                                state: /DetailReducer.DetailState.movie,
                                then: MovieDetailView.init
                            )
                            CaseLet(
                                state: /DetailReducer.DetailState.tvShow,
                                then: TVDetailView.init
                            )
                            CaseLet(
                                state: /DetailReducer.DetailState.person,
                                then: PersonDetailView.init
                            )
                        }
                    }
                }
            }
            .navigationTitle(viewStore.media.displayName)
            .task {
                viewStore.send(.fetchDetails)
            }
        }
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            store: .init(
                initialState: .init(media: mockMedias[2]),
                reducer: DetailReducer()
            )
        )
        .frame(height: 850)
    }
}
#endif
