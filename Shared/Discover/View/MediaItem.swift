//
//  MediaItem.swift
//  MovieDB
//
//  Created by allie on 11/11/2022.
//

import SwiftUI

struct MediaItem: View {
    let media: Media
    var imageSize: ImageSize = .fixed
    
    enum ImageSize {
        case fixed, aspectRatio
    }
    
    var image: some View {
        URLImage(media.displayPosterPath)
            .cornerRadius(10)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // MARK: - 海报
            if imageSize == .fixed {
                image
                    .frame(width: 150, height: 225)
            } else {
                image
                    .aspectRatio(150/225, contentMode: .fill)
            }
            
            HStack {
                // MARK: - 电影/剧集名
                Text(media.displayName)
                    .lineLimit(2)
                    .font(.headline)
    
                Spacer()
                
                media.voteAverage
                    .map { score in
                        Text("\(score, specifier: "%.1f")")
                            .font(.subheadline)
                            .foregroundColor(score.scoreColor)
                    }
            }
            .padding(.horizontal)
            
            Group {
                if media.mediaType == .person {
                    // MARK: - 代表作
                    Text(media.knownFor?.compactMap(\.title) ?? [], format: .list(type: .and))
                } else {
                    // MARK: - 发布日期
                    Text(media.releaseDate ?? media.firstAirDate ?? "")
                }
            }
            .lineLimit(2)
            .foregroundColor(.secondary)
            .font(.subheadline)
            .padding(.horizontal)
        }
        .frame(maxWidth: imageSize == .fixed ? 150 : .infinity)
    }
}

struct MediaItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(mockMedias) { media in
                MediaItem(media: media)
            }
        }
        .frame(height: 850)
    }
}
