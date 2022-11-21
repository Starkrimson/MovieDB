//
//  DetailHeader.swift
//  MovieDB
//
//  Created by allie on 15/7/2022.
//

import SwiftUI

struct MediaHeader: View {
    let backdropPath: String?
    let posterPath: String?
    let name: String
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    // MARK: - 背景图
                    URLImage(backdropPath?.imagePath(.multiFaces(w: 1000, h: 450)))
                        .frame(width: proxy.size.width)
                    
                    // MARK: - 渐变
                    LinearGradient(
                        colors: [
                            Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0.8),
                            Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    // MARK: - 海报
                    URLImage(posterPath?.imagePath())
                        .cornerRadius(6)
                        .aspectRatio(440/660, contentMode: .fit)
                        .padding(.vertical, 20)
                        .padding(.leading, 20)
                }
            }
            .aspectRatio(1000/450, contentMode: .fill)
            
            // MARK: - 电影名
            Text(name)
                .font(.largeTitle)
                .padding()
        }
    }
}

extension DetailView {
    
    struct Header: View {
        var state: DetailReducer.State
        
        var body: some View {
            switch state.media.mediaType {
            case .movie, .tv:
                MediaHeader(
                    backdropPath: state.media.backdropPath,
                    posterPath: state.media.posterPath,
                    name: state.media.displayName
                )
                
            default :
                HStack(alignment: .top, spacing: 0) {
                    // MARK: - 人像
                    URLImage(state.media.profilePath?.imagePath(.face(w: 276, h: 350)))
                        .frame(width: 157, height: 200)
                        .cornerRadius(4)
                    
                    // MARK: - 个人信息
                    VStack(alignment: .leading, spacing: 0) {
                        Text(state.media.displayName)
                            .font(.largeTitle)
                        
                        if case .person(let personState) = state.detail {
                            DetailView.Material(detail: .person(personState.person))
                        }
                    }
                    .padding(.leading)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
    }
}

#if DEBUG
struct DetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Header(state: .init(media: mockMedias[1]))
    }
}
#endif
