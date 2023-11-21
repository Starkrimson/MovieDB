//
//  DetailImages.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI
import ComposableArchitecture

extension DetailView {

    struct Images: View {
        let store: StoreOf<ImageGridReducer>

        @Environment(\.openURL) var openURL

        var body: some View {
            WithViewStore(store) {
                $0
            } content: { viewStore in
                VStack(alignment: .leading) {
                    // MARK: - 图片列表
                    ScrollView(.horizontal) {
                        HStack {
                            if viewStore.selectedImageType == .videos {
                                videoStack
                            } else {
                                imageStack
                            }
                            NavigationLink(route: .imageGrid(viewStore.state)) {
                                HStack(spacing: 3) {
                                    Text("VIEW MORE".localized)
                                    Image(systemName: "chevron.right.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                                .padding()
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                    }
                    .header {
                        // MARK: - 图片类型
                        Picker("MEDIA".localized, selection: viewStore.$selectedImageType) {
                            ForEach(
                                viewStore.videos.isEmpty
                                ? viewStore.images.imageTypes
                                : [.videos] + viewStore.images.imageTypes
                            ) { type in
                                Text(type.description)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .footer {
                        // MARK: - 查看全部
                        NavigationLink(route: .imageGrid(viewStore.state)) {
                            Text("\("VIEW ALL".localized)\(viewStore.selectedImageType.description)")
                        }
                    }
                }
            }
        }

        @ViewBuilder
        var imageStack: some View {
            WithViewStore(store) {
                $0
            } content: { viewStore in
                ForEach(
                    viewStore.images.images(of: viewStore.selectedImageType).prefix(10)
                ) { poster in
                    NavigationLink(route: .image(.init(image: poster))) {
                        URLImage(poster.filePath?.imagePath(
                            viewStore.selectedImageType == .posters
                            ? .best(width: 188, height: 282)
                            : .face(width: 500, height: 282)
                        ))
                        .frame(
                            width: viewStore.selectedImageType == .posters ? 94 : 250,
                            height: 141
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }

        @ViewBuilder
        var videoStack: some View {
            WithViewStore(store) {
                $0
            } content: { viewStore in
                ForEach(
                    viewStore.videos.prefix(10)
                ) { video in
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
                        .frame(width: 188, height: 141)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#if DEBUG
struct DetailImages_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Images(
            store: .init(
                initialState: .init(
                    images: mockMovies[0].images ?? .init(),
                    videos: mockMovies[0].videos?.results ?? [],
                    selectedImageType: .videos
                ),
                reducer: {
                    ImageGridReducer()
                }
            )
        )
    }
}
#endif
