//
//  MovieDBTests.swift
//  MovieDBTests (iOS)
//
//  Created by allie on 11/7/2022.
//

import XCTest
import ComposableArchitecture
@testable import MovieDB

@MainActor
final class MovieDBTests: XCTestCase {

    func testFetchPopularShows() async {
        let store = TestStore(
            initialState: .init(),
            reducer: DiscoverReducer()
        )

        // 获取热门电影
        _ = await store.send(.fetchPopular(.movie))
        // 成功接收到热门电影
        await store.receive(.fetchPopularDone(kind: .movie, result: .success(mockMediaMovies))) {
            $0.popularMovies = .init(uniqueElements: mockMediaMovies.map {
                DetailReducer.State(media: $0)
            })
        }

        // 获取热门电视节目
        _ = await store.send(.fetchPopular(.tvShow))
        // 成功接收热门电视节目
        await store.receive(.fetchPopularDone(kind: .tvShow, result: .success(mockMediaTVShows))) {
            $0.popularTVShows = .init(uniqueElements: mockMediaTVShows.map {
                DetailReducer.State(media: $0)
            })
        }
    }

    func testFetchMovie() async {
        let store = TestStore(
            initialState: .init(media: mockMedias[0]),
            reducer: DetailReducer()
        )

        _ = await store.send(.fetchDetails)
        await store.receive(.fetchDetailsResponse(.success(.movie(mockMovies[0])))) {
            $0.status = .normal
            $0.detail = .movie(.init(mockMovies[0]))
        }
    }

    func testFetchTVShow() async {
        let store = TestStore(
            initialState: .init(media: mockMedias[1], status: .normal),
            reducer: DetailReducer()
        )

        _ = await store.send(.fetchDetails) {
            $0.status = .loading
        }

        await store.receive(.fetchDetailsResponse(.success(.tvShow(mockTVShows[0])))) {
            $0.status = .normal
            $0.detail = .tvShow(.init(mockTVShows[0]))
        }
    }

    func testFetchMovieCollection() async {
        let store = TestStore(
            initialState: .init(belongsTo: .init(id: 1)),
            reducer: MovieCollectionReducer()
        )

        _ = await store.send(.fetchCollection)
        await store.receive(.fetchCollectionDone(.success(mockCollection))) {
            $0.status = .normal
            $0.collection = mockCollection
            $0.movies = .init(uniqueElements: mockCollection.parts?.map {
                DetailReducer.State(media: $0)
            } ?? [])
        }
    }

    func testFetchTVSeason() async {
        let store = TestStore(
            initialState: .init(tvID: 1, seasonNumber: 2, showName: ""),
            reducer: SeasonReducer()
        )

        _ = await store.send(.fetchSeason)
        await store.receive(.fetchSeasonDone(.success(mockTVShows[0].seasons![0]))) {
            $0.status = .normal
            $0.season = mockTVShows[0].seasons![0]
        }
    }
}
