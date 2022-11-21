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
        WithViewStore(store) {
            $0
        } content: { viewStore in
            Group {
                switch viewStore.status {
                case .loading where viewStore.list.isEmpty:
                    ProgressView()

                case .error(let error):
                    ErrorTips(error: error)

                case .normal where viewStore.list.isEmpty:
                    Text("NOT FOUND".localized)

                default:
                    ScrollView {
                        MediaGrid(
                            list: viewStore.list,
                            canLoadMore: !viewStore.isLastPage
                        ) {
                            viewStore.send(.search(page: viewStore.page + 1))
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("SEARCH RESULTS TITLE".localized(arguments: viewStore.query))
        }
    }
}

#if DEBUG
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
#endif
