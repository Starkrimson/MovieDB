//
//  DetailImages.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {
    
    struct Images: View {
        var images: Media.Images
        var videos: [Media.Video] = []
        @State var selectedImageType: Media.ImageType = .backdrops
        
        @Environment(\.openURL) var openURL
        
        var body: some View {
            VStack(alignment: .leading) {
                // MARK: - 图片列表
                ScrollView(.horizontal) {
                    HStack {
                        if selectedImageType == .videos {
                            videoStack
                        } else {
                            imageStack
                        }
                        NavigationLink {
                            ImageGridView(
                                images: images,
                                videos: videos,
                                selectedImageType: selectedImageType
                            )
                        } label: {
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
                    Picker("MEDIA".localized, selection: $selectedImageType) {
                        ForEach(
                            videos.isEmpty
                            ? images.imageTypes
                            : [.videos] + images.imageTypes
                        ) { type in
                            Text(type.description)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .footer {
                    // MARK: - 查看全部
                    NavigationLink {
                        ImageGridView(
                            images: images,
                            videos: videos,
                            selectedImageType: selectedImageType
                        )
                    } label: {
                        Text("\("VIEW ALL".localized)\(selectedImageType.description)")
                    }
                }
            }
        }
        
        @ViewBuilder
        var imageStack: some View {
            ForEach(
                images.images(of: selectedImageType).prefix(10)
            ) { poster in
                NavigationLink {
                    ImageBrowser(image: poster)
                } label: {
                    URLImage(poster.filePath?.imagePath(
                        selectedImageType == .posters
                        ? .best(w: 188, h: 282)
                        : .face(w: 500, h: 282)
                    ))
                    .frame(
                        width: selectedImageType == .posters ? 94 : 250,
                        height: 141
                    )
                }
                .buttonStyle(.plain)
            }
        }
        
        @ViewBuilder
        var videoStack: some View {
            ForEach(
                videos.prefix(10)
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

struct DetailImages_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Images(
            images: mockMovies[0].images ?? .init(),
            videos: mockMovies[0].videos?.results ?? [],
            selectedImageType: .videos
        )
    }
}
