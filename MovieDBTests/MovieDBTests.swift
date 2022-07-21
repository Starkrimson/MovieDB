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
        
        store.send(.fetchDetails(mediaType: .movie)) {
            $0.loading = true
        }
        store.receive(.fetchDetailsDone(.success(.movie(mockMovies[0])))) {
            $0.loading = false
            $0.movie = mockMovies[0]
            $0.directors = mockMovies[0].credits?.crew?.filter { $0.department == "Directing" } ?? []
            $0.writers = mockMovies[0].credits?.crew?.filter { $0.department == "Writing" } ?? []
        }
        
        store.send(.fetchDetails(mediaType: .tv)) {
            $0.loading = true
        }
        store.receive(.fetchDetailsDone(.success(.tv(mockTVShows[0])))) {
            $0.loading = false
            $0.tv = mockTVShows[0]
            $0.directors = mockTVShows[0].createdBy ?? []
        }
        
        store.send(.fetchDetails(mediaType: .person)) {
            $0.loading = true
        }
        store.receive(.fetchDetailsDone(.success(.person(mockPeople[0])))) {
            $0.loading = false
            $0.personState = .init(mockPeople[0])
        }
        
        store.send(.fetchDetails(mediaType: .all)) {
            $0.loading = true
        }
        store.receive(.fetchDetailsDone(.failure(.sample("Something Went Wrong")))) {
            $0.loading = false
        }
    }
}
