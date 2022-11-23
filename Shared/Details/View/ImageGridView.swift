//
//  ImageGridView.swift
//  MovieDB
//
//  Created by allie on 25/7/2022.
//

import SwiftUI

struct ImageGridView: View {
    let images: Media.Images
    var videos: [Media.Video] = []

    @State var selectedImageType: Media.ImageType = .backdrops

    @Environment(\.openURL) var openURL

    var body: some View {
        ScrollView {
            GridLayout(
                estimatedItemWidth: selectedImageType == .posters ? 188 : 375
            ) {
                if selectedImageType == .videos {
                    videoStack
                } else {
                    ForEach(
                        images.images(of: selectedImageType)
                    ) { item in
                        NavigationLink {
                            ImageBrowser(image: item)
                        } label: {
                            Item(image: item, type: selectedImageType)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .toolbar {
            Picker("MEDIA".localized, selection: $selectedImageType) {
                ForEach(
                    videos.isEmpty
                    ? images.imageTypes
                    : [.videos] + images.imageTypes
                ) {
                    Text($0.description)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
        }
        .navigationTitle("MEDIA".localized)
    }

    @ViewBuilder
    var videoStack: some View {
        ForEach(videos) { video in
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
            ImageGridView(
                images: mockMovies[0].images ?? .init(),
                selectedImageType: .backdrops
            )
        }
    }
}
#endif
