//
//  MovieDBTests.swift
//  MovieDBTests (iOS)
//
//  Created by allie on 11/7/2022.
//

import XCTest
import ComposableArchitecture
@testable import MovieDB

final class MovieDBTests: XCTestCase {

    func testFetchPopularShows() {
        let store = TestStore(
            initialState: .init(),
            reducer: discoverReducer,
            environment: .init(mainQueue: .immediate, dbClient: .failing)
        )
        
        store.environment.dbClient.popular = {
            Effect(value:  $0 == .movie ? mockMovies : mockTVShows)
        }
        
        // 获取热门电影
        store.send(.fetchPopular(.movie))
        // 成功接收到热门电影
        store.receive(.fetchPopularDone(kind: .movie, result: .success(mockMovies))) {
            $0.popularMovies = .init(uniqueElements: mockMovies)
        }
        
        // 获取热门电视节目
        store.send(.fetchPopular(.tv))
        // 成功接收热门电视节目
        store.receive(.fetchPopularDone(kind: .tv, result: .success(mockTVShows))) {
            $0.popularTVShows = .init(uniqueElements: mockTVShows)
        }
    }
}

private let mockMovies: [MovieTV] = [
    .init(
        title: "小黄人大眼萌2：格鲁的崛起",
        originalTitle: "Minions: The Rise of Gru",
        id: 438148
    ),
    .init(
        title: "奇异博士2：疯狂多元宇宙",
        originalTitle: "Doctor Strange in the Multiverse of Madness",
        id: 453395
    ),
    .init(
        title: "雷神4：爱与雷霆",
        originalTitle: "Thor: Love and Thunder",
        id: 616037
    ),
]

private let mockTVShows: [MovieTV] = [
    .init(
        name: "Stranger Things",
        originalName: "Stranger Things",
        id: 66732
    ),
    .init(
        name: "黑袍纠察队",
        originalName: "The Boys",
        id: 76479
    ),
    .init(
        name: "终极名单",
        originalName: "The Terminal List",
        id: 120911
    ),
]
