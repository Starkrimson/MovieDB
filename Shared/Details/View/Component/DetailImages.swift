//
//  DetailImages.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI
import Kingfisher

extension DetailView {
    
    struct Images: View {
        var images: Media.Images
        
        var body: some View {
            VStack {
                // MARK: - 图片类型
                Picker(selection: .constant(("海报"))) {
                    ForEach(["海报", "剧照"], id: \.self) { index in
                        Text("\(index)")
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
                        ForEach(images.posters?.prefix(10) ?? []) { poster in
                            KFImage(URL(string: poster.filePath?.imagePath(.best(w: 188, h: 282)) ?? ""))
                                .placeholder {
                                    Image(systemName: "photo")
                                        .font(.title)
                                }
                                .resizable()
                                .background(Color.secondary)
                                .frame(width: 94, height: 141)
                                .padding(.leading)
                        }
                    }
                }
            }
        }
    }
}

struct DetailImages_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Images(images: mockMovies[0].images ?? .init())
    }
}
