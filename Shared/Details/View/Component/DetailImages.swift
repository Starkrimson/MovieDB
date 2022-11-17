//
//  DetailImages.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {
    
    struct Images: View {
        @State var selectedImageType: Media.ImageType = .backdrop
        var images: Media.Images
        
        var body: some View {
            VStack(alignment: .leading) {
                // MARK: - 图片列表
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(
                            selectedImageType == .poster
                            ? images.posters?.prefix(10) ?? []
                            : images.backdrops?.prefix(10) ?? []
                        ) { poster in
                            NavigationLink {
                                ImageBrowser(image: poster)
                            } label: {
                                URLImage(poster.filePath?.imagePath(
                                    selectedImageType == .poster
                                    ? .best(w: 188, h: 282)
                                    : .face(w: 500, h: 282)
                                ))
                                .frame(
                                    width: selectedImageType == .poster ? 94 : 250,
                                    height: 141
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        NavigationLink {
                            ImageGridView(images: images, selectedImageType: selectedImageType)
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
                        ForEach(Media.ImageType.allCases) { type in
                            Text(type.description)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .footer {
                    // MARK: - 查看全部
                    NavigationLink {
                        ImageGridView(images: images, selectedImageType: selectedImageType)
                    } label: {
                        Text("\("VIEW ALL".localized)\(selectedImageType.description)")
                    }
                }
            }
        }
    }
}

struct DetailImages_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Images(
            images: mockMovies[0].images ?? .init()
        )
    }
}
