//
//  ContentView.swift
//  Shared
//
//  Created by allie on 30/6/2022.
//

import SwiftUI
import CoreData
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<MovieDBReducer> = .init(
        initialState: .init(),
        reducer: MovieDBReducer()
    )
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationSplitView {
                List(
                    selection: viewStore.binding(
                        get: { $0.selectedTab },
                        send: MovieDBReducer.Action.tabSelected
                    )
                ) {
                    Section("MovieDB") {
                        ForEach(MovieDBReducer.Tab.allCases.filter { $0 != .search }) { item in
                            Label(item.rawValue.localized, systemImage: item.systemImage)
                        }
                    }
                }
                .searchable(
                    text: viewStore.binding(\.search.$query),
                    placement: .sidebar,
                    prompt: "SEARCH PLACEHOLDER".localized
                )
                .onSubmit(of: .search) {
                    viewStore.send(.search(.search()))
                }
            } detail: {
                NavigationStack {
                    switch viewStore.selectedTab {
                    case .search:
                        SearchResultsView(store: store.scope(
                            state: \.search, action: MovieDBReducer.Action.search)
                        )
                        
                    case .discover:
                        DiscoverView(
                            store: store.scope(
                                state: \.discover,
                                action: MovieDBReducer.Action.discover
                            )
                        )
                        
                    case .movies:
                        DiscoverMediaView(
                            store: store.scope(
                                state: \.movies,
                                action: MovieDBReducer.Action.movies
                            )
                        )
                        
                    case .tvShows:
                        DiscoverMediaView(
                            store: store.scope(
                                state: \.tvShows,
                                action: MovieDBReducer.Action.tvShows
                            )
                        )
                        
                    case .people:
                        DiscoverMediaView(
                            store: store.scope(
                                state: \.people,
                                action: MovieDBReducer.Action.people
                            )
                        )

                    case .none:
                        EmptyView()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
