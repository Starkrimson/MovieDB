//
//  PersistenceClient.swift
//  MovieDB
//
//  Created by allie on 23/11/2022.
//

import Foundation
import ComposableArchitecture

struct PersistenceClient {
    var favourite: @Sendable (MarkAsFavourite) throws -> Favourite?
    var favouriteList: @Sendable () throws -> [Favourite]
    var favouriteItem: @Sendable (Int?) throws -> Favourite?
}

extension PersistenceClient {
    enum MarkAsFavourite {
        case remove(Favourite)
        case favourite(Media)
    }
}

extension DependencyValues {
    var persistenceClient: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}

extension PersistenceClient: DependencyKey {
    static var liveValue: PersistenceClient = Self { mark  in
        let viewContext = PersistenceController.shared.container.viewContext
        switch mark {
        case .favourite(let media):
            let favourite = Favourite(context: viewContext)
            favourite.mediaType = media.mediaType?.rawValue
            favourite.id = media.id?.int32 ?? 0
            favourite.title = media.displayName
            favourite.overview = media.overview
            favourite.posterPath = media.posterPath ?? media.profilePath
            favourite.backdropPath = media.backdropPath
            favourite.releaseDate = media.releaseDate ?? media.firstAirDate
            try viewContext.save()
            return favourite
        case .remove(let favourite):
            viewContext.delete(favourite)
            try viewContext.save()
            return nil
        }
    } favouriteList: {
        let request = Favourite.fetchRequest()
        return try PersistenceController.shared.container.viewContext.fetch(request)
    } favouriteItem: { id in
        guard let id else { return nil }
        let request = Favourite.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id == %i", id)
        return try PersistenceController.shared.container.viewContext.fetch(request).first
    }

    static var previewValue: PersistenceClient = Self { mark  in
        switch mark {
        case .favourite(let media):
            let favourite = Favourite(context: PersistenceController.preview.container.viewContext)
            favourite.id = 30
            favourite.mediaType = "movie"
            return favourite
        case .remove(let favourite):
            return nil
        }
    } favouriteList: {
        mockMedias.map {
            let favourite = Favourite(context: PersistenceController.preview.container.viewContext)
            favourite.id = Int32($0.id ?? 0)
            favourite.mediaType = $0.mediaType?.rawValue
            favourite.title = $0.displayName
            favourite.posterPath = $0.posterPath ?? $0.profilePath
            return favourite
        }
    } favouriteItem: { _ in
        nil
    }

    static var testValue: PersistenceClient = previewValue
}
