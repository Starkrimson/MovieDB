//
//  ImageGridView.swift
//  MovieDB
//
//  Created by allie on 25/7/2022.
//

import SwiftUI

struct ImageGridView: View {
    let images: Media.Images
    
    @State var selectedImageType: Media.ImageType = .backdrop
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("媒体", selection: $selectedImageType) {
                ForEach(Media.ImageType.allCases) {
                    Text($0.description)
                        .tag($0)
                }
            }
            .padding()
            .pickerStyle(.segmented)
            ScrollView {
                GridLayout(
                    estimatedItemWidth: selectedImageType == .poster ? 188 : 375
                )() {
                    ForEach(
                        selectedImageType == .poster
                        ? images.posters ?? []
                        : images.backdrops ?? []
                    ) { backdrop in
                        VStack {
                            URLImage(backdrop.filePath?.imagePath(
                                selectedImageType == .poster
                                ? .best(w: 188, h: 282)
                                : .face(w: 500, h: 282)
                            ))
                            .aspectRatio(selectedImageType == .poster ? 188/282 : 500/282, contentMode: .fill)
                            Text("\(backdrop.width ?? 0) x \(backdrop.height ?? 0)")
                        }
                    }
                }
            }
        }
    }
}

struct ImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGridView(images: mockMovies[0].images ?? .init(),
                      selectedImageType: .backdrop)
    }
}
