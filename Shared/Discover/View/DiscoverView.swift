//
//  DiscoverView.swift
//  MovieDB (iOS)
//
//  Created by allie on 1/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct DiscoverView: View {
    let store: StoreOf<DiscoverReducer>

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            ScrollView {
                Header(media: viewStore.randomMedia)
                if let error = viewStore.error {
                    ErrorTips(error: error)
                }
                SectionTitle(
                    title: "POPULAR".localized,
                    selectedIndex: viewStore.$popularIndex,
                    labels: ["MOVIES".localized, "TV SHOWS".localized]
                )
                .padding(.top)
                if viewStore.popularIndex == 0 {
                    CardRow(store: store.scope(state: \.popularMovies, action: { .popularMovie($0) }))
                } else {
                    CardRow(store: store.scope(state: \.popularTVShows, action: DiscoverReducer.Action.popularTVShow))
                }

                SectionTitle(
                    title: "TRENDING".localized,
                    selectedIndex: viewStore.$trendingIndex,
                    labels: ["TODAY".localized, "THIS WEEK".localized]
                )
                if viewStore.trendingIndex == 0 {
                    CardRow(store: store.scope(state: \.dailyTrending, action: DiscoverReducer.Action.dailyTrending))
                } else {
                    CardRow(store: store.scope(state: \.weeklyTrending, action: DiscoverReducer.Action.weeklyTrending))
                }
            }
            .task {
                await viewStore.send(.task).finish()
            }
            .frame(minWidth: 320)
            .navigationTitle("DISCOVER".localized)
        }
    }
}

private extension SearchFieldPlacement {

    static var discoverSearchPlacement: SearchFieldPlacement {
        #if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad
        ? toolbar
        : navigationBarDrawer(displayMode: .always)
        #else
        automatic
        #endif
    }
}

#if DEBUG
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView(
            store: .init(
                initialState: .init(),
                reducer: { DiscoverReducer() }
            )
        )
    }
}
#endif
