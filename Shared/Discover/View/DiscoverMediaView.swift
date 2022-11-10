//
//  DiscoverMediaView.swift
//  MovieDB
//
//  Created by allie on 1/8/2022.
//

import SwiftUI
import ComposableArchitecture

struct DiscoverMediaView: View {
    let store: StoreOf<DiscoverMediaReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                MediaGrid(
                    list: viewStore.list,
                    canLoadMore: !viewStore.isLastPage && viewStore.status != .loading
                ) {
                    viewStore.send(.fetchMedia(loadMore: true))
                }
                .padding()
                if viewStore.status == .loading {
                    ProgressView()
                }
                
                if case let .error(error) = viewStore.status {
                    ErrorTips(error: error)
                }
            }
            .navigationTitle(viewStore.name)
            .onAppear {
                viewStore.send(.fetchMedia())
            }
            .toolbar {
                ToolbarItem {
                    Picker("Menu", selection: viewStore.binding(
                        get: \.quickSort, send: DiscoverMediaReducer.Action.setQuickSort
                    )) {
                        ForEach(DiscoverMediaReducer.State.QuickSort.allCases) { item in
                            Text(item.rawValue.localized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}

struct DiscoverMediaView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiscoverMediaView(store: .init(
                initialState: .init(mediaType: .movie, name: "Movie", totalPages: 2),
                reducer: DiscoverMediaReducer()
            ))
        }
    }
}
