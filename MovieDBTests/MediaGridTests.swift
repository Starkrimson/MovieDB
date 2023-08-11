//
//  MediaGridTests.swift
//  MovieDBTests
//
//  Created by allie on 11/11/2022.
//

import XCTest
import ComposableArchitecture
@testable import MovieDB

@MainActor
final class MediaGridTests: XCTestCase {

    // swiftlint:disable function_body_length
    func testMovieGrid() async {
        let store = TestStore(
            initialState: DiscoverMediaReducer.State(mediaType: .movie, name: ""),
            reducer: { DiscoverMediaReducer() }
        )

        // 加载第一页数据
        let firstPage = PageResponses(page: 1, totalPages: 2, results: [mockMediaMovies[0]])
        store.dependencies.dbClient.discover = { _, _ in firstPage }

        await store.send(.fetchMedia())
        await store.receive(.fetchMediaDone(loadMore: false, result: .success(firstPage))) { state in
            state.status = .normal
            state.page = 1
            state.totalPages = 2
            state.list = .init(uniqueElements: firstPage.results!)
        }

        // 加载第二页数据
        let secondPage = PageResponses(page: 2, totalPages: 2, results: [mockMediaMovies[1]])
        store.dependencies.dbClient.discover = { _, _ in secondPage}
        await store.send(.fetchMedia(loadMore: true)) {
            $0.status = .loading
        }
        await store.receive(.fetchMediaDone(loadMore: true, result: .success(secondPage))) {
            $0.status = .normal
            $0.page = 2
            $0.list = .init(uniqueElements: firstPage.results! + secondPage.results!)
        }

        // 切换高分排序
        store.dependencies.dbClient.discover = { _, _ in firstPage }
        await store.send(.setQuickSort(.topRated)) {
            $0.quickSort = .topRated
            $0.filter = .init(sortBy: "vote_average.desc", minimumUserVotes: 300)
        }
        await store.receive(.fetchMedia()) {
            $0.page = 1
            $0.totalPages = 1
            $0.status = .loading
        }
        await store.receive(.fetchMediaDone(loadMore: false, result: .success(firstPage))) {
            $0.status = .normal
            $0.page = 1
            $0.totalPages = 2
            $0.list = .init(uniqueElements: firstPage.results!)
        }

        // 设置筛选项，最低分=5
        await store.send(.filter(.set(\.$minimumUserScore, 5))) {
            $0.filter.minimumUserScore = 5
        }
        await store.receive(.fetchMedia()) {
            $0.totalPages = 1
            $0.status = .loading
        }
        await store.receive(.fetchMediaDone(loadMore: false, result: .success(firstPage))) {
            $0.totalPages = 2
            $0.status = .normal
        }

        // 重置筛选
        await store.send(.filter(.reset)) {
            $0.quickSort = .popular
            $0.filter = .init()
        }
        await store.receive(.fetchMedia()) {
            $0.totalPages = 1
            $0.status = .loading
        }
        await store.receive(.fetchMediaDone(loadMore: false, result: .success(firstPage))) {
            $0.totalPages = 2
            $0.status = .normal
        }
    }

    func testPersonGrid() async {
        let store = TestStore(
            initialState: DiscoverMediaReducer.State(mediaType: .person, name: ""),
            reducer: { DiscoverMediaReducer() }
        )

        let firstPage = PageResponses(page: 1, totalPages: 2, results: [mockMedias[2]])
        store.dependencies.dbClient.popular = { _, _ in firstPage }
        await store.send(.fetchMedia())
        await store.receive(.fetchMediaDone(loadMore: false, result: .success(firstPage))) {
            $0.page = 1
            $0.totalPages = 2
            $0.status = .normal
            $0.list = .init(uniqueElements: [mockMedias[2]])
        }
    }
}
