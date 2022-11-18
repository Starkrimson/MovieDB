//
//  DiscoverCardRow.swift
//  MovieDB
//
//  Created by allie on 1/7/2022.
//

import SwiftUI
import ComposableArchitecture

extension DiscoverView {
    
    struct CardRow: View {
        let store: Store<IdentifiedArrayOf<DetailReducer.State>, (DetailReducer.State.ID, DetailReducer.Action)>
        
        var body: some View {
            // MARK: - 横向滑动电影/剧集
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    ForEachStore(store) { detailStore in
                        WithViewStore(detailStore, observe: { $0 }) { detailViewStore in
                            NavigationLink {
                                DetailView(store: detailStore)
                            } label: {
                                MediaItem(media: detailViewStore.media)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#if DEBUG
struct DiscoverCardRow_Previews: PreviewProvider {

    static var previews: some View {
        DiscoverView.CardRow(
            store: Store(
                initialState: .init(popularMovies: .init(uniqueElements: mockMedias.map {
                    DetailReducer.State(media: $0)
                })),
                reducer: DiscoverReducer()
            )
            .scope(state: \.popularMovies, action: DiscoverReducer.Action.popularMovie)
        )
    }
}
#endif
