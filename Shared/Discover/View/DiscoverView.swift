//
//  DiscoverView.swift
//  MovieDB (iOS)
//
//  Created by allie on 1/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct DiscoverView: View {
    @State var keyword: String = ""
    @State var trendingIndex: Int = 0

    let store: Store<DiscoverState, DiscoverAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                Header(keyword: $keyword)
                if let error = viewStore.error {
                    ErrorTips(error: error)
                }
                SectionTitle(
                    title: "热门",
                    selectedIndex: viewStore.binding(\.$popularIndex),
                    labels: ["电影", "电视播出"]
                )
                CardRow(list: viewStore.popularList)
                SectionTitle(
                    title: "趋势",
                    selectedIndex: viewStore.binding(\.$trendingIndex),
                    labels: ["今日", "本周"]
                )
                CardRow(list: viewStore.trendingList)
            }
            .onAppear {
                viewStore.send(.fetchPopular(.movie))
                viewStore.send(.fetchPopular(.tv))
                viewStore.send(.fetchTrending(timeWindow: .day))
                viewStore.send(.fetchTrending(timeWindow: .week))
            }
            .frame(minWidth: 320)
            .navigationTitle("Discover")
            .navigationDestination(for: Media.self) { media in
                DetailView(store: .init(
                    initialState: .init(media: media),
                    reducer: detailReducer,
                    environment: .init(mainQueue: .main, dbClient: .live)
                ))
            }
            .navigationDestination(for: Media.Cast.self) { cast in
                DetailView(store: .init(
                    initialState: .init(media: .from(cast)),
                    reducer: detailReducer,
                    environment: .init(mainQueue: .main, dbClient: .live)
                ))
            }
            .navigationDestination(for: Media.Crew.self) { cast in
                DetailView(store: .init(
                    initialState: .init(media: .from(cast)),
                    reducer: detailReducer,
                    environment: .init(mainQueue: .main, dbClient: .live)
                ))
            }
            .navigationDestination(for: Media.CombinedCredits.Credit.self) {
                DetailView(store: .init(
                    initialState: .init(media: .from($0)),
                    reducer: detailReducer,
                    environment: .init(mainQueue: .main, dbClient: .live)
                ))
            }
            .navigationDestination(for: Media.Credits.self) { element in
                CreditView(credit: element)
            }
            .navigationDestination(for: Media.Images.self) { element in
                ImageGridView(images: element)
            }
            .navigationDestination(for: BelongsToCollection.self) { element in
                MovieCollectionView(store: .init(
                    initialState: .init(belongsTo: element),
                    reducer: movieCollectionReducer,
                    environment: .init(mainQueue: .main, dbClient: .live)
                ))
            }
            .navigation { destination in
                switch destination {
                case .seasonList(let showName, let seasons):
                    SeasonList(showName: showName, seasons: seasons)
                }
            }
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
