//
//  DiscoverCardRow.swift
//  MovieDB
//
//  Created by allie on 1/7/2022.
//

import SwiftUI
import ComposableArchitecture

extension DiscoverView {

    struct CardRow: View {
        let store: Store<IdentifiedArrayOf<DetailReducer.State>, IdentifiedActionOf<DetailReducer>>

        var body: some View {
            // MARK: - 横向滑动电影/剧集
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    ForEachStore(store) { detailStore in
                        DetailItem(store: detailStore)
                    }
                }
                .padding()
            }
        }
    }
}

#if DEBUG
struct DiscoverCardRow_Previews: PreviewProvider {

    static let store: StoreOf<DiscoverReducer> = .init(initialState: .init()) {
        DiscoverReducer()
    }

    static let listStore: Store<
        IdentifiedArrayOf<DetailReducer.State>, IdentifiedActionOf<DetailReducer>
    > = store.scope(state: \.popularMovies, action: DiscoverReducer.Action.popularMovie)

    static var previews: some View {
        DiscoverView.CardRow(store: listStore)
    }
}
#endif
