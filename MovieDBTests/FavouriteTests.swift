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
        let favourites = [
            CDFavourite(context: PersistenceController.preview.container.viewContext)
        ]

        let store = TestStore(initialState: FavouriteReducer.State()) {
            FavouriteReducer()
        } withDependencies: {
            $0.persistenceClient.favouriteList = { _, _, _ in favourites }
        }

        await store.send(.fetchFavouriteList)
        await store.receive(.fetchFavouriteListDone(.success(favourites))) {
            $0.list = .init(uniqueElements: favourites.map {
                DetailReducer.State(media: .from($0))
            })
        }
    }

    func testModifyFilterItems() async {
        let store = TestStore(
            initialState: FavouriteReducer.State(),
            reducer: { FavouriteReducer() },
            withDependencies: {
                $0.persistenceClient.favouriteList = { _, _, _ in [] }
            }
        )

        await store.send(.binding(.set(\.$selectedMediaType, .movie))) {
            $0.selectedMediaType = .movie
        }
        await store.receive(.fetchFavouriteList)
        await store.receive(.fetchFavouriteListDone(.success([])))

        await store.send(.binding(.set(\.sort.$ascending, true))) {
            $0.sort.ascending = true
        }
        await store.receive(.fetchFavouriteList)
        await store.receive(.fetchFavouriteListDone(.success([])))

        await store.send(.binding(.set(\.sort.$sortByKey, "releaseDate"))) {
            $0.sort.sortByKey = "releaseDate"
        }
        await store.receive(.fetchFavouriteList)
        await store.receive(.fetchFavouriteListDone(.success([])))
    }
}
