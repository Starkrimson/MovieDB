//
//  DiscoverView.swift
//  MovieDB (iOS)
//
//  Created by allie on 1/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct DiscoverView: View {
    @State var trendingIndex: Int = 0

    let store: StoreOf<DiscoverReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                Header(backdropPath: viewStore.backdropPath)
                if let error = viewStore.error {
                    ErrorTips(error: error)
                }
                SectionTitle(
                    title: "POPULAR".localized,
                    selectedIndex: viewStore.binding(\.$popularIndex),
                    labels: ["MOVIES".localized, "TVSHOWS".localized]
                )
                CardRow(mediaType: viewStore.popularIndex == 0 ? .movie : .tv,
                        list: viewStore.popularList)
                SectionTitle(
                    title: "TRENDING".localized,
                    selectedIndex: viewStore.binding(\.$trendingIndex),
                    labels: ["TODAY".localized, "THIS WEEK".localized]
                )
                CardRow(list: viewStore.trendingList)
            }
            .task {
                await viewStore.send(.task).finish()
            }
            .frame(minWidth: 320)
            .navigationTitle("Discover")
            .appDestination()
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

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {        
        DiscoverView(
            store: .init(
                initialState: .init(),
                reducer: DiscoverReducer()
            )
        )
    }
}
