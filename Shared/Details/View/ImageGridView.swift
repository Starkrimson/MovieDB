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
        ScrollView {
            GridLayout(
                estimatedItemWidth: selectedImageType == .poster ? 188 : 375
            ) {
                ForEach(
                    selectedImageType == .poster
                    ? images.posters ?? []
                    : images.backdrops ?? []
                ) { item in
                    Item(image: item, type: selectedImageType)
                }
            }
            .padding()
        }
        .toolbar {
            Picker("MEDIA".localized, selection: $selectedImageType) {
                ForEach(Media.ImageType.allCases) {
                    Text($0.description)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
        }
        .navigationTitle("MEDIA".localized)
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
                    type == .poster
                    ? .best(w: 188, h: 282)
                    : .face(w: 500, h: 282)
                ))
                .aspectRatio(type == .poster ? 188/282 : 500/282, contentMode: .fill)
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

struct ImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGridView(images: mockMovies[0].images ?? .init(),
                      selectedImageType: .backdrop)
    }
}
