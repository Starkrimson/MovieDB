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
