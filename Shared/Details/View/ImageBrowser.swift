//
//  ImageBrowser.swift
//  MovieDB
//
//  Created by allie on 16/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct ImageBrowser: View {
    let store: StoreOf<ImageReducer>

    @Environment(\.openURL) private var openURL

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            let urlImage = URLImage(viewStore.image.filePath?.imagePath(.original))
            urlImage
                .aspectRatio(viewStore.ratio, contentMode: .fit)
                .toolbar {
                    Button {
                        openURL(viewStore.originURL)
                    } label: {
                        Label("VIEW ON WEB".localized, systemImage: "link.circle")
                    }
                    ShareLink(item: urlImage, preview: .init(viewStore.image.filePath ?? "", image: urlImage))
                }
        }
    }
}

#if DEBUG
struct ImageBrowser_Previews: PreviewProvider {
    static var previews: some View {
        ImageBrowser(
            store: .init(
                initialState: .init(image: mockMovies[0].images!.backdrops![0])
            ) {
                ImageReducer()
            }
        )
    }
}
#endif
