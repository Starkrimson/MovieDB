//
//  PersonDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct PersonDetailView: View {
    let store: Store<DetailState, DetailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    // MARK: - 人像
                    KFImage(URL(string: viewStore.media.profilePath?.imagePath(.face(w: 276, h: 350)) ?? ""))
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
                        Text(viewStore.media.displayName)
                            .font(.largeTitle)
                        
                        if let person = viewStore.personState?.person {
                            DetailView.Material(detail: .person(person))
                                .padding(.top)
                        }
                    }
                    .padding(.leading)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
    
                IfLetStore(
                    store.scope(state: \.personState),
                    then: { movieStore in
                        WithViewStore(movieStore) { movieViewStore in
                            VStack(alignment: .leading) {
                                // MARK: - 图片
                                ScrollView(.horizontal) {
                                    HStack(spacing: 0) {
                                        ForEach(movieViewStore.images) { image in
                                            KFImage(URL(string: image.filePath?.imagePath(.face(w: 276, h: 350)) ?? ""))
                                                .placeholder {
                                                    Image(systemName: "photo")
                                                        .font(.largeTitle)
                                                }
                                                .resizable()
                                                .background(Color.secondary)
                                                .frame(width: 138, height: 175)
                                                .cornerRadius(4)
                                                .padding(.leading)
                                        }
                                    }
                                }
                                
                                // MARK: - 代表作
                                if !movieViewStore.knownFor.isEmpty {
                                    Text("代表作")
                                        .font(.title2.weight(.medium))
                                        .padding(.leading)
                                    
                                    ScrollView(.horizontal) {
                                        HStack(spacing: 0) {
                                            ForEach(movieViewStore.knownFor) { item in
                                                NavigationLink(
                                                    value: Media(
                                                        mediaType: item.mediaType,
                                                        id: item.id
                                                    )
                                                ) {
                                                    DiscoverView.CardItem(
                                                        posterPath: item.posterPath?.imagePath() ?? "",
                                                        score: nil,
                                                        title: item.title ?? item.name ?? "",
                                                        date: ""
                                                    )
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                                
                                // MARK: - 参演
                                if !movieViewStore.acting.isEmpty {
                                    Text("参演")
                                        .font(.title2.weight(.medium))
                                        .padding(.leading)

                                    ForEach(movieViewStore.acting) { item in
                                        HStack {
                                            Text((item.releaseDate ?? item.firstAirDate ?? "").prefix(4))
                                            NavigationLink(
                                                value: Media(mediaType: item.mediaType, id: item.id)
                                            ) {
                                                Text(item.title ?? item.name ?? "")
                                                    .font(.headline)
                                            }
                                            .buttonStyle(.plain)
                                            Text("饰演")
                                                .foregroundColor(.secondary)
                                            Text(item.character ?? "")
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // MARK: - 导演
                                ForEach(movieViewStore.crew.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                    Text(key)
                                        .font(.title2.weight(.medium))
                                        .padding(.leading)

                                    ForEach(value) { item in
                                        HStack {
                                            Text((item.releaseDate ?? item.firstAirDate ?? "").prefix(4))
                                            Text(item.title ?? item.name ?? "")
                                                .font(.headline)
                                            Text(item.job ?? "")
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    },
                    else: ProgressView.init
                )
            }
            .navigationTitle(viewStore.media.displayName)
            .onAppear {
                viewStore.send(.fetchDetails(mediaType: .person))
            }
        }
    }
}

struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailView(
            store: .init(
                initialState: .init(media: mockMedias[2]),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .previews)
            )
        )
        .frame(minWidth: 720, minHeight: 1920)
    }
}
