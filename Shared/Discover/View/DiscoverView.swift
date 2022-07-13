//
//  DiscoverView.swift
//  MovieDB (iOS)
//
//  Created by allie on 1/7/2022.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct DiscoverView: View {
    @State var keyword: String = ""
    @State var popularIndex: Int = 0
    @State var trendingIndex: Int = 0

    let store: Store<DiscoverState, DiscoverAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                Header(keyword: $keyword)
                if let error = viewStore.error?.localizedDescription {
                    Label(error, systemImage: "exclamationmark.circle")
                }
                SectionTitle(title: "热门", selectedIndex: $popularIndex, labels: ["电影", "电视播出"])
                CardRow(
                    list: popularIndex == 0
                    ? viewStore.popularMovies.elements
                    : viewStore.popularTVShows.elements
                )
                SectionTitle(title: "趋势", selectedIndex: $trendingIndex, labels: ["今日", "本周"])
                CardRow(
                    list: trendingIndex == 0
                    ? viewStore.dailyTrending.elements
                    : viewStore.weeklyTrending.elements
                )
            }
            .onAppear {
                viewStore.send(.fetchPopular(.movie))
                viewStore.send(.fetchPopular(.tv))
                viewStore.send(.fetchTrending(timeWindow: .day))
                viewStore.send(.fetchTrending(timeWindow: .week))
            }
            .frame(minWidth: 320)
            .navigationTitle("Discover")
        }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView(
            store: .init(
                initialState: .init(),
                reducer: discoverReducer,
                environment: .init(mainQueue: .main, dbClient: .failing)
            )
        )
    }
}
