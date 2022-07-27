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
            Effect(value:  $0 == .movie ? mockMediaMovies : mockMediaTVShows)
        }
        
        // 获取热门电影
        store.send(.fetchPopular(.movie))
        // 成功接收到热门电影
        store.receive(.fetchPopularDone(kind: .movie, result: .success(mockMediaMovies))) {
            $0.popularMovies = .init(uniqueElements: mockMediaMovies)
        }
        
        // 获取热门电视节目
        store.send(.fetchPopular(.tv))
        // 成功接收热门电视节目
        store.receive(.fetchPopularDone(kind: .tv, result: .success(mockMediaTVShows))) {
            $0.popularTVShows = .init(uniqueElements: mockMediaTVShows)
        }
    }
    
    func testFetchDetails() {
        let store = TestStore(
            initialState: .init(media: mockMedias[0]),
            reducer: detailReducer,
            environment: .init(mainQueue: .immediate, dbClient: .failing)
        )
        
        store.environment.dbClient.details = { mediaType, _ in
            switch mediaType {
            case .all:
                return Effect(error: .sample("Something Went Wrong"))
            case .movie:
                return Effect(value: .movie(mockMovies[0]))
            case .tv:
                return Effect(value: .tv(mockTVShows[0]))
            case .person:
                return Effect(value: .person(mockPeople[0]))
            }
        }
        
        store.send(.fetchDetails(mediaType: .movie))
        store.receive(.fetchDetailsDone(.success(.movie(mockMovies[0])))) {
            $0.status = .normal
            $0.movieState = .init(mockMovies[0])
        }
        
        store.send(.fetchDetails(mediaType: .tv)) {
            $0.status = .loading
        }
        store.receive(.fetchDetailsDone(.success(.tv(mockTVShows[0])))) {
            $0.status = .normal
            $0.tvState = .init(mockTVShows[0])
        }
        
        store.send(.fetchDetails(mediaType: .person)) {
            $0.status = .loading
        }
        store.receive(.fetchDetailsDone(.success(.person(mockPeople[0])))) {
            $0.status = .normal
            $0.personState = .init(mockPeople[0])
        }
        
        store.send(.fetchDetails(mediaType: .all)) {
            $0.status = .loading
        }
        store.receive(.fetchDetailsDone(.failure(.sample("Something Went Wrong")))) {
            $0.status = .error(.sample("Something Went Wrong"))
        }
    }
    
    func testSelectImageType() {
        let store = TestStore(
            initialState: .init(media: mockMedias[0], movieState: .init(mockMovies[0])),
            reducer: detailReducer,
            environment: .init(mainQueue: .immediate, dbClient: .previews)
        )
        
        store.send(.selectImageType(mediaType: .movie, imageType: .poster)) {
            $0.movieState?.selectedImageType = .poster
        }
        
        store.send(.selectImageType(mediaType: .movie, imageType: .backdrop)) {
            $0.movieState?.selectedImageType = .backdrop
        }
    }
    
    func testFetchMovieCollection() {
        let store = TestStore(
            initialState: .init(),
            reducer: movieCollectionReducer,
            environment: .init(mainQueue: .immediate, dbClient: .previews)
        )
        
        store.send(.fetchCollection(id: 1))
        store.receive(.fetchCollectionDone(.success(mockCollection))) {
            $0.status = .normal
            $0.collection = mockCollection
        }
    }
}
