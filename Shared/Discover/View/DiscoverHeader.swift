//
//  DiscoverHeader.swift
//  MovieDB
//
//  Created by allie on 1/7/2022.
//

import SwiftUI

extension DiscoverView {
    struct Header: View {
        @Binding var keyword: String
        
        var body: some View {
            ZStack {
                // MARK: - 背景图
                GeometryReader { proxy in
                    URLImage("/8bcoRX3hQRHufLPSDREdvr3YMXx.jpg".imagePath(.duotone(w: 1920, h: 600)))
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: 240)
                        .clipped()
                }
                
                // MARK: - 渐变遮罩
                LinearGradient(
                    colors: [
                        Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0.8),
                        Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                VStack(alignment: .leading) {
                    Text("欢迎。")
                        .font(.title)
                        .fontWeight(.medium)
                    
                    Text("这里有海量的电影、剧集和人物等你来发现。快来探索吧！")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    HStack {
                        // MARK: - 搜索栏
                        ZStack(alignment: .leading) {
                            TextField("", text: $keyword)
                                .frame(height: 46)
                                .foregroundColor(Color.gray)
                                .textFieldStyle(.plain)
                                .accentColor(.green)
                            if keyword.isEmpty {
                                Text("搜索电影、剧集、人物...")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        
                        // MARK: - 搜索按钮
                        Button(action: {
                            print(keyword)
                        }) {
                            Text("Search")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .foregroundColor(.white)
                        }
                        .frame(height: 46)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 30/255.0, green: 213/255.0, blue: 169/255.0),
                                    Color(red: 1/255.0, green: 180/255.0, blue: 228/255.0),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(23)
                        .buttonStyle(.plain)
                    }
                    .frame(height: 46)
                    .background(Color.white)
                    .cornerRadius(23)
                    .padding(.top, 15)
                }
                .padding()
            }
            .frame(height: 240)
        }
    }
}

struct DiscoverHeader_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView.Header(keyword: .constant(""))
    }
}
