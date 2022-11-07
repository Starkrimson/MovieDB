//
//  SearchResultsView.swift
//  MovieDB
//
//  Created by allie on 7/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct SearchResultsView: View {
    let store: StoreOf<SearchReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                MediaGrid(
                    list: viewStore.list,
                    canLoadMore: !viewStore.isLastPage
                ) {
                    viewStore.send(.search(page: viewStore.page + 1))
                }
                .padding()
            }
            .navigationTitle("\"\(viewStore.query)\" 的结果")
        }
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(
            store: .init(
                initialState: .init(),
                reducer: SearchReducer()
            )
        )
    }
}
