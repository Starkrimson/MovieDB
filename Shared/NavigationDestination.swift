//
//  NavigationDestination.swift
//  MovieDB
//
//  Created by allie on 28/7/2022.
//

import Foundation
import SwiftUI

enum NavigationDestination: Hashable {
    /// 详情
    case mediaDetail(media: Media, mediaType: MediaType? = nil)
    /// 电影系列
    case movieCollection(BelongsToCollection)
    /// 电视分季列表
    case seasonList(showName: String, tvID: Int, seasons: [Season])
    /// 某季分集列表
    case episodeList(showName: String, tvID: Int, seasonNumber: Int)
    /// keyword 或者 genre id 媒体列表
    case discoverMedia(mediaType: MediaType, name: String, keywords: [Int] = [], genres: [Int] = [])
    /// 图片 Grid
    case imageGrid(Media.Images)
    /// 演职员表
    case credit(Media.Credits)
}

extension View {

    func navigation<C>(
        @ViewBuilder destination: @escaping (NavigationDestination) -> C
    ) -> some View where C : View {
        navigationDestination(for: NavigationDestination.self, destination: destination)
    }
    
    func appDestination() -> some View {
        navigation { destination in
            switch destination {
            case let .mediaDetail(media, mediaType):
                DetailView(store: .init(
                    initialState: .init(media: media, mediaType: mediaType ?? media.mediaType ?? .movie),
                    reducer: DetailReducer()
                ))
            case let .movieCollection(belongsTo):
                MovieCollectionView(store: .init(
                    initialState: .init(belongsTo: belongsTo),
                    reducer: movieCollectionReducer,
                    environment: .init(mainQueue: .main, dbClient: .live)
                ))
            case .seasonList(let showName, let tvID, let seasons):
                SeasonList(showName: showName, tvID: tvID, seasons: seasons)
            case .episodeList(showName: let showName, tvID: let tvID, seasonNumber: let seasonNumber):
                EpisodeList(store: .init(
                    initialState: .init(tvID: tvID, seasonNumber: seasonNumber, showName: showName),
                    reducer: seasonReducer,
                    environment: .init(mainQueue: .main, dbClient: .live)
                ))
            case let .discoverMedia(mediaType, name, keywords, genres):
                DiscoverMediaView(store: .init(
                    initialState: .init(mediaType: mediaType, name: name, withKeywords: keywords, withGenres: genres),
                    reducer: discoverMediaReducer,
                    environment: .init(mainQueue: .main, dbClient: .live)
                ))
            case .imageGrid(let images):
                ImageGridView(images: images)
            case .credit(let credit):
                CreditView(credit: credit)
            }
        }
    }
}

extension NavigationLink where Destination == Never {

    init(destination: NavigationDestination, label: () -> Label) {
        self.init(value: destination, label: label)
    }
}
