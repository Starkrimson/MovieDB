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
                // MARK: - 图片类型
                Picker(selection: $selectedImageType) {
                    ForEach(Media.ImageType.allCases) { type in
                        Text(type.description)
                            .tag(type)
                    }
                } label: {
                    Text("媒体")
                        .font(.title2.weight(.medium))
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)
                
                // MARK: - 图片列表
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(
                            selectedImageType == .poster
                            ? images.posters?.prefix(10) ?? []
                            : images.backdrops?.prefix(10) ?? []
                        ) { poster in
                            URLImage(poster.filePath?.imagePath(
                                selectedImageType == .poster
                                ? .best(w: 188, h: 282)
                                : .face(w: 500, h: 282)
                            ))
                            .frame(
                                width: selectedImageType == .poster ? 94 : 250,
                                height: 141
                            )
                            .padding(.leading)
                        }
                        NavigationLink {
                            ImageGridView(images: images)
                        } label: {
                            HStack(spacing: 3) {
                                Text("查看更多")
                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                            .padding()
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // MARK: - 查看全部
                NavigationLink {
                    ImageGridView(images: images)
                } label: {
                    Text("查看全部\(selectedImageType.description)")
                        .font(.title3.weight(.medium))
                        .padding(.horizontal)
                }
                .buttonStyle(.plain)
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
