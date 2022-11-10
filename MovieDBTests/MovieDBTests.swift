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
                DetailReducer.State(media: $0, mediaType: .movie)
            })
        }
        
        // 获取热门电视节目
        _ = await store.send(.fetchPopular(.tv))
        // 成功接收热门电视节目
        await store.receive(.fetchPopularDone(kind: .tv, result: .success(mockMediaTVShows))) {
            $0.popularTVShows = .init(uniqueElements: mockMediaTVShows.map {
                DetailReducer.State(media: $0, mediaType: .tv)
            })
        }
    }
    
    func testFetchDetails() async {
        let store = TestStore(
            initialState: .init(media: mockMedias[0], mediaType: .movie),
            reducer: DetailReducer()
        )
        
        _ = await store.send(.fetchDetails(mediaType: .movie))
        await store.receive(.fetchDetailsResponse(.success(.movie(mockMovies[0])))) {
            $0.status = .normal
            $0.detail = .movie(.init(mockMovies[0]))
        }
        
        _ = await store.send(.fetchDetails(mediaType: .tv)) {
            $0.status = .loading
        }
        await store.receive(.fetchDetailsResponse(.success(.tv(mockTVShows[0])))) {
            $0.status = .normal
            $0.detail = .tv(.init(mockTVShows[0]))
        }
        
        _ = await store.send(.fetchDetails(mediaType: .person)) {
            $0.status = .loading
        }
        await store.receive(.fetchDetailsResponse(.success(.person(mockPeople[0])))) {
            $0.status = .normal
            $0.detail = .person(.init(mockPeople[0]))
        }
        
        _ = await store.send(.fetchDetails(mediaType: .all)) {
            $0.status = .loading
        }
        await store.receive(.fetchDetailsResponse(.failure(AppError.sample("Something Went Wrong")))) {
            $0.status = .error("Something Went Wrong")
        }
    }
    
    func testFetchMovieCollection() async {
        let store = TestStore(
            initialState: .init(belongsTo: .init(id: 1)),
            reducer: movieCollectionReducer,
            environment: .init(mainQueue: .immediate, dbClient: .previews)
        )
        
        _ = await store.send(.fetchCollection)
        await store.receive(.fetchCollectionDone(.success(mockCollection))) {
            $0.status = .normal
            $0.collection = mockCollection
        }
    }
    
    func testFetchTVSeason() async {
        let store = TestStore(
            initialState: .init(tvID: 1, seasonNumber: 2, showName: ""),
            reducer: seasonReducer,
            environment: .init(mainQueue: .immediate, dbClient: .previews)
        )
        
        _ = await store.send(.fetchSeason)
        await store.receive(.fetchSeasonDone(.success(mockTVShows[0].seasons![0]))) {
            $0.status = .normal
            $0.season = mockTVShows[0].seasons![0]
        }
    }
}
