//
//  DiscoverHeader.swift
//  MovieDB
//
//  Created by allie on 1/7/2022.
//

import SwiftUI

extension DiscoverView {
    struct Header: View {
        let media: Media?

        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    // MARK: - 背景图
                    GeometryReader { proxy in
                        URLImage(media?.backdropPath?.imagePath(.duotone(width: 1920, height: 600)))
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: 240)
                            .clipped()
                    }

                    // MARK: - 渐变遮罩
                    LinearGradient(
                        colors: [
                            Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0.8),
                            Color(red: 3/255.0, green: 37/255.0, blue: 68/255.0, opacity: 0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )

                    VStack(alignment: .leading) {
                        Text("WELCOME TITLE".localized)
                            .font(.title)

                        Text("WELCOME CONTENT".localized)
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .padding()
                }
                .frame(height: 240)

                if let displayName = media?.displayName {
                    NavigationLink {
                        DetailView(store: .init(
                            initialState: .init(media: media!),
                            reducer: { DetailReducer() }
                        ))
                    } label: {
                        HStack(spacing: 3) {
                            Text(displayName)
                            Image(systemName: "chevron.right")
                        }
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#if DEBUG
struct DiscoverHeader_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView.Header(media: mockMedias[0])
    }
}
#endif
