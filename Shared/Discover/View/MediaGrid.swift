//
//  MediaGrid.swift
//  MovieDB
//
//  Created by allie on 5/8/2022.
//

import SwiftUI
import ComposableArchitecture

struct MediaGrid: View {
    var list: IdentifiedArrayOf<Media> = []
    var canLoadMore = false
    var onLoadMore: ()->()
    
    var body: some View {
        VStack {
            GridLayout(estimatedItemWidth: 200) {
                ForEach(list) { item in
                    NavigationLink {
                        DetailView(store: .init(
                            initialState: .init(media: item),
                            reducer: DetailReducer()
                        ))
                    } label: {
                        MediaItem(media: item, imageSize: .aspectRatio)
                    }
                    .buttonStyle(.plain)
                }
            }
            if canLoadMore {
                Button("LOAD MORE".localized) {
                    onLoadMore()
                }
            }
        }
    }
}

#if DEBUG
struct MediaGrid_Previews: PreviewProvider {
    static var previews: some View {
        MediaGrid(list: .init(uniqueElements: mockMedias)) { }
            .frame(height: 350)
    }
}
#endif
