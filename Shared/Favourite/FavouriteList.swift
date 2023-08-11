//
//  FavouriteList.swift
//  MovieDB
//
//  Created by allie on 29/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct FavouriteList: View {
    let store: StoreOf<FavouriteReducer>

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            ScrollView {
                GridLayout(estimatedItemWidth: 200) {
                    ForEachStore(
                        store.scope(
                            state: \.list,
                            action: FavouriteReducer.Action.media
                        )
                    ) {
                        DetailItem(store: $0, imageSize: .aspectRatio)
                    }
                }
                .padding()
            }
            .task {
                await viewStore.send(.fetchFavouriteList).finish()
            }
            .navigationTitle("MY FAVOURITES".localized)
            .toolbar {
                ToolbarItem {
                    Picker(
                        viewStore.selectedMediaType.localizedDescription,
                        selection: viewStore.$selectedMediaType
                    ) {
                        ForEach(MediaType.allCases) {
                            Text($0.localizedDescription)
                        }
                    }
                }
                ToolbarItem {
                    SortMenu(store: store.scope(
                        state: \.sort,
                        action: FavouriteReducer.Action.sort
                    ))
                }
            }
        }
    }
}

#if DEBUG
struct FavouriteList_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteList(store: .init(
            initialState: .init(),
            reducer: { FavouriteReducer() }
        ))
    }
}
#endif
