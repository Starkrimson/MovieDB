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
                        selection: viewStore.binding(\.$selectedMediaType)
                    ) {
                        ForEach(MediaType.allCases) {
                            Text($0.localizedDescription)
                        }
                    }
                }
                ToolbarItem {
                    Menu {
                        Picker(
                            "FILTER BY".localized,
                            selection: viewStore.binding(\.$sortByKeyPath)
                        ) {
                            ForEach(viewStore.keyPaths, id: \.self) { keyPath in
                                Text("\(keyPath.label.localized)")
                            }
                        }
                        .pickerStyle(.inline)

                        Picker(
                            "ORDER".localized,
                            selection: viewStore.binding(\.$ascending)
                        ) {
                            ForEach([true, false], id: \.self) {
                                Text($0 ? "ASCENDING".localized : "DESCENDING".localized)
                            }
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Text(viewStore.sortByKeyPath.label.localized
                             + " "
                             + (viewStore.ascending ? "ASCENDING".localized : "DESCENDING".localized))
                    }
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
            reducer: FavouriteReducer()
        ))
    }
}
#endif
