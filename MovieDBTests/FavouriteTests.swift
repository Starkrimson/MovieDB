//
//  FavouriteTests.swift
//  MovieDBTests
//
//  Created by allie on 1/12/2022.
//

import XCTest
import ComposableArchitecture
@testable import MovieDB

@MainActor
final class FavouriteTests: XCTestCase {
    func testFetchFavouriteList() async {
        let store = TestStore(
            initialState: .init(),
            reducer: FavouriteReducer()
        )

        let favourites = [
            Favourite(context: PersistenceController.preview.container.viewContext)
        ]

        store.dependencies.persistenceClient.favouriteList = { _, _ in favourites }

        await store.send(.fetchFavouriteList)
        await store.receive(.fetchFavouriteListDone(.success(favourites))) {
            $0.list = .init(uniqueElements: favourites.map {
                DetailReducer.State(media: .from($0))
            })
        }
    }

    func testModifyFilterItems() async {
        let store = TestStore(
            initialState: .init(),
            reducer: FavouriteReducer()
        )

        store.dependencies.persistenceClient.favouriteList = { _, _ in [] }

        await store.send(.binding(.set(\.$selectedMediaType, .movie))) {
            $0.selectedMediaType = .movie
        }
        await store.receive(.fetchFavouriteList)
        await store.receive(.fetchFavouriteListDone(.success([])))

        await store.send(.binding(.set(\.$ascending, true))) {
            $0.ascending = true
        }
        await store.receive(.fetchFavouriteList)
        await store.receive(.fetchFavouriteListDone(.success([])))

        await store.send(.binding(.set(\.$sortByKeyPath, \Favourite.releaseDate))) {
            $0.sortByKeyPath = \Favourite.releaseDate
        }
        await store.receive(.fetchFavouriteList)
        await store.receive(.fetchFavouriteListDone(.success([])))
    }
}
