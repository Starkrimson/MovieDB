//
//  ImageGridView.swift
//  MovieDB
//
//  Created by allie on 25/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct ImageGridView: View {
    let store: StoreOf<ImageGridReducer>

    @Environment(\.openURL) var openURL

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            ScrollView {
                GridLayout(
                    estimatedItemWidth: viewStore.selectedImageType == .posters ? 188 : 375
                ) {
                    if viewStore.selectedImageType == .videos {
                        ForEach(viewStore.videos) { video in
                            Button {
                                if let url = video.key?.ytPlayURL {
                                    openURL(url)
                                }
                            } label: {
                                ZStack(alignment: .bottomLeading) {
                                    ZStack {
                                        URLImage(video.key?.ytImagePath)

                                        Image(systemName: "play.circle.fill")
                                            .font(.largeTitle)
                                    }
                                    HStack {
                                        Text(video.name ?? "")
                                            .lineLimit(2)
                                            .padding(4)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(6)
                                        Spacer()
                                        Image(systemName: "link")
                                    }
                                    .font(.caption)
                                    .padding(6)
                                }
                                .aspectRatio(240/180, contentMode: .fill)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        ForEach(
                            viewStore.images.images(of: viewStore.selectedImageType)
                        ) { item in
                            NavigationLink(route: .image(.init(image: item))) {
                                Item(image: item, type: viewStore.selectedImageType)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .toolbar {
                Picker("MEDIA".localized, selection: viewStore.$selectedImageType) {
                    ForEach(
                        viewStore.videos.isEmpty
                        ? viewStore.images.imageTypes
                        : [.videos] + viewStore.images.imageTypes
                    ) {
                        Text($0.description)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle("MEDIA".localized)
        }
    }
}

extension ImageGridView {

    struct Item: View {
        var image: Media.Image
        var type: Media.ImageType

        @State var over = false
        @Environment(\.openURL) var openURL

        var originalURL: URL {
            guard let string = image.filePath?.imagePath(.original),
             let url = URL(string: string) else {
                return URL(filePath: "/null")
            }
            return url
        }

        @ViewBuilder
        var buttons: some View {
            Button {
                openURL(originalURL)
            } label: {
                Label("VIEW ON WEB".localized, systemImage: "link.circle")
            }

            let image = URLImage(originalURL)
            ShareLink(
                item: image,
                preview: .init(
                    originalURL.lastPathComponent,
                    image: image
                )
            )
        }

        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                URLImage(image.filePath?.imagePath(
                    type == .posters
                    ? .best(width: 188, height: 282)
                    : .face(width: 500, height: 282)
                ))
                .aspectRatio(type == .posters ? 188/282 : 500/282, contentMode: .fill)
                if over {
                    VStack(alignment: .trailing) {
                        buttons
                        Text("\(image.width ?? 0) x \(image.height ?? 0)")
                            .font(.subheadline)
                            .padding(3)
                            .background(.ultraThinMaterial)
                            .cornerRadius(5)
                    }
                    .padding(6)
                }
            }
            .onHover {
                over = $0
            }
            .contextMenu {
                buttons
            }
        }
    }
}

#if DEBUG
struct ImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ImageGridView(store: .init(
                initialState: .init(
                    images: mockMovies[0].images ?? .init(),
                    selectedImageType: .backdrops
                ),
                reducer: {
                    ImageGridReducer()
                })
            )
        }
    }
}
#endif
