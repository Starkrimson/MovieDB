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

struct MediaGrid_Previews: PreviewProvider {
    static var previews: some View {
        MediaGrid(list: .init(uniqueElements: mockMedias)) { }
    }
}
