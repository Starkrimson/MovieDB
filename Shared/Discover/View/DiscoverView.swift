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

    let store: Store<DiscoverState, DiscoverAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                if !viewStore.isSearchResultListHidden {
                    ResultList(
                        list: viewStore.search.list,
                        canLoadMore: !viewStore.search.isLastPage
                    ) {
                        viewStore.send(.search(page: viewStore.search.page + 1))
                    }
                } else {
                    Header()
                    if let error = viewStore.error {
                        ErrorTips(error: error)
                    }
                    SectionTitle(
                        title: "热门",
                        selectedIndex: viewStore.binding(\.$popularIndex),
                        labels: ["电影", "电视播出"]
                    )
                    CardRow(mediaType: viewStore.popularIndex == 0 ? .movie : .tv,
                        list: viewStore.popularList)
                    SectionTitle(
                        title: "趋势",
                        selectedIndex: viewStore.binding(\.$trendingIndex),
                        labels: ["今日", "本周"]
                    )
                    CardRow(list: viewStore.trendingList)
                }
                
            }
            .onAppear {
                viewStore.send(.fetchPopular(.movie))
                viewStore.send(.fetchPopular(.tv))
                viewStore.send(.fetchTrending(timeWindow: .day))
                viewStore.send(.fetchTrending(timeWindow: .week))
            }
            .searchable(
                text: viewStore.binding(\.search.$query),
                placement: .discoverSearchPlacement,
                prompt: "搜索电影、剧集、人物..."
            )
            .onSubmit(of: .search) {
                viewStore.send(.search())
            }
            .frame(minWidth: 320)
            .navigationTitle("Discover")
            .appDestination()
        }
    }
}

struct ResultList: View {
    var list: IdentifiedArrayOf<Media> = []
    var canLoadMore = false
    var onLoadMore: ()->()
    
    var body: some View {
        VStack {
            GridLayout(estimatedItemWidth: 200) {
                ForEach(list) { item in
                    NavigationLink(destination: .mediaDetail(media: item)) {
                        VStack {
                            URLImage(item.displayPosterPath)
                                .aspectRatio(150/225, contentMode: .fill)
                                .cornerRadius(6)
                            Text(item.displayName)
                                .lineLimit(2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            if canLoadMore {
                Button("载入更多") {
                    onLoadMore()
                }
            }
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
        ResultList(list: .init(uniqueElements: mockMedias)) {  }
        
        DiscoverView(
            store: .init(
                initialState: .init(),
                reducer: discoverReducer,
                environment: .init(mainQueue: .main, dbClient: .failing)
            )
        )
    }
}
