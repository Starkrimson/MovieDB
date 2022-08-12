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
            reducer: discoverReducer,
            environment: .init(mainQueue: .immediate, dbClient: .previews)
        )
        
        // 获取热门电影
        _ = await store.send(.fetchPopular(.movie))
        // 成功接收到热门电影
        await store.receive(.fetchPopularDone(kind: .movie, result: .success(mockMediaMovies))) {
            $0.popularMovies = .init(uniqueElements: mockMediaMovies)
        }
        
        // 获取热门电视节目
        _ = await store.send(.fetchPopular(.tv))
        // 成功接收热门电视节目
        await store.receive(.fetchPopularDone(kind: .tv, result: .success(mockMediaTVShows))) {
            $0.popularTVShows = .init(uniqueElements: mockMediaTVShows)
        }
    }
    
    func testFetchDetails() async {
        let store = TestStore(
            initialState: .init(media: mockMedias[0], mediaType: .movie),
            reducer: detailReducer,
            environment: .init(mainQueue: .immediate, dbClient: .previews)
        )
        
        _ = await store.send(.fetchDetails(mediaType: .movie))
        await store.receive(.fetchDetailsResponse(.success(.movie(mockMovies[0])))) {
            $0.status = .normal
            $0.movieState = .init(mockMovies[0])
        }
        
        _ = await store.send(.fetchDetails(mediaType: .tv)) {
            $0.status = .loading
        }
        await store.receive(.fetchDetailsResponse(.success(.tv(mockTVShows[0])))) {
            $0.status = .normal
            $0.tvState = .init(mockTVShows[0])
        }
        
        _ = await store.send(.fetchDetails(mediaType: .person)) {
            $0.status = .loading
        }
        await store.receive(.fetchDetailsResponse(.success(.person(mockPeople[0])))) {
            $0.status = .normal
            $0.personState = .init(mockPeople[0])
        }
        
        _ = await store.send(.fetchDetails(mediaType: .all)) {
            $0.status = .loading
        }
        await store.receive(.fetchDetailsResponse(.failure(AppError.sample("Something Went Wrong")))) {
            $0.status = .error(.sample("Something Went Wrong"))
        }
    }
    
    func testSelectImageType() {
        let store = TestStore(
            initialState: .init(media: mockMedias[0], mediaType: .movie, movieState: .init(mockMovies[0])),
            reducer: detailReducer,
            environment: .init(mainQueue: .immediate, dbClient: .previews)
        )
        
        store.send(.selectImageType(imageType: .poster)) {
            $0.movieState?.selectedImageType = .poster
        }
        
        store.send(.selectImageType(imageType: .backdrop)) {
            $0.movieState?.selectedImageType = .backdrop
        }
    }
    
    func testFetchMovieCollection() {
        let store = TestStore(
            initialState: .init(belongsTo: .init(id: 1)),
            reducer: movieCollectionReducer,
            environment: .init(mainQueue: .immediate, dbClient: .previews)
        )
        
        store.send(.fetchCollection)
        store.receive(.fetchCollectionDone(.success(mockCollection))) {
            $0.status = .normal
            $0.collection = mockCollection
        }
    }
    
    func testFetchTVSeason() {
        let store = TestStore(
            initialState: .init(tvID: 1, seasonNumber: 2, showName: ""),
            reducer: seasonReducer,
            environment: .init(mainQueue: .immediate, dbClient: .previews)
        )
        
        store.send(.fetchSeason)
        store.receive(.fetchSeasonDone(.success(mockTVShows[0].seasons![0]))) {
            $0.status = .normal
            $0.season = mockTVShows[0].seasons![0]
        }
    }
}
