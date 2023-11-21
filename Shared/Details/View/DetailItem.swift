//
//  DetailItem.swift
//  MovieDB
//
//  Created by allie on 30/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct DetailItem: View {
    let store: StoreOf<DetailReducer>
    var imageSize: MediaItem.ImageSize = .fixed

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            NavigationLink(route: .detail(viewStore.state)) {
                MediaItem(media: viewStore.media, imageSize: imageSize)
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
struct DetailItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(mockMedias) { media in
                DetailItem(store: .init(
                    initialState: .init(media: media),
                    reducer: { DetailReducer() }
                ))
            }
        }
    }
}
#endif
