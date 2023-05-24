//
//  WatchlistView.swift
//  MovieDB
//
//  Created by allie on 24/5/2023.
//

import SwiftUI
import ComposableArchitecture

struct WatchlistView: View {
    let store: StoreOf<WatchlistReducer>

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            ScrollView {
                GridLayout(estimatedItemWidth: 200) {
                    ForEachStore(
                        store.scope(
                            state: \.list,
                            action: WatchlistReducer.Action.media
                        )
                    ) {
                        DetailItem(store: $0, imageSize: .aspectRatio)
                    }
                }
                .padding()
            }
            .task {
                await viewStore.send(.fetchWatchlist).finish()
            }
            .navigationTitle("WATCHLIST".localized)
            .toolbar {
                ToolbarItem {
                    SortMenu(store: store.scope(
                        state: \.sort,
                        action: WatchlistReducer.Action.sort
                    ))
                }
            }
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView(store: .init(
            initialState: .init(),
            reducer: WatchlistReducer()
        ))
    }
}
