//
//  DetailHeader.swift
//  MovieDB
//
//  Created by allie on 15/7/2022.
//

import SwiftUI
import Kingfisher

extension DetailView {
    
    struct Header: View {
        var state: DetailState
        
        var body: some View {
            switch state.media.mediaType {
            case .movie, .tv:
                VStack {
                    GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                // MARK: - 背景图
                                KFImage(URL(
                                    string: state.media.backdropPath?.imagePath(.multiFaces(w: 1000, h: 450)) ?? "")
                                )
                                .resizable()
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
                                KFImage(URL(string: state.media.posterPath?.imagePath() ?? ""))
                                    .resizable()
                                    .cornerRadius(6)
                                    .aspectRatio(440/660, contentMode: .fit)
                                    .padding(.vertical, 20)
                                    .padding(.leading, 20)
                            }
                        }
                    .aspectRatio(1000/450, contentMode: .fill)
                    
                    // MARK: - 电影名
                    Text(state.media.displayName)
                        .font(.largeTitle)
                        .padding()
                }
                
            default :
                HStack(alignment: .top, spacing: 0) {
                    // MARK: - 人像
                    KFImage(URL(string: state.media.profilePath?.imagePath(.face(w: 276, h: 350)) ?? ""))
                        .placeholder {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                        }
                        .resizable()
                        .background(Color.secondary)
                        .frame(width: 157, height: 200)
                        .cornerRadius(4)
                    
                    // MARK: - 个人信息
                    VStack(alignment: .leading, spacing: 0) {
                        Text(state.media.displayName)
                            .font(.largeTitle)
                        
                        if let person = state.personState?.person {
                            DetailView.Material(detail: .person(person))
                                .padding(.top)
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

struct DetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Header(state: .init(media: mockMedias[1]))
    }
}
