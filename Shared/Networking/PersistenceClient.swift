//
//  PersistenceClient.swift
//  MovieDB
//
//  Created by allie on 23/11/2022.
//

import Foundation
import ComposableArchitecture
import CoreData

struct PersistenceClient {
    var addItemToDatabase: @Sendable (Item) throws -> NSManagedObject?
    var deleteFromDatabase: @Sendable (NSManagedObject) throws -> NSManagedObject?

    var favouriteList: @Sendable (_ filterBy: MediaType, _ sortByKey: String, _ ascending: Bool) throws -> [CDFavourite]
    var favouriteItem: @Sendable (Int?) throws -> CDFavourite?

    var externalLinks: @Sendable () throws -> [CDExternalLink]

    var watchlist: @Sendable (_ filterBy: MediaType, _ sortByKey: String, _ ascending: Bool) throws -> [CDWatch]
    var watchItem: @Sendable (Int?) throws -> CDWatch?
}

extension PersistenceClient {
    enum Item {
        case favourite(Media)
        case watch(Media)
        case externalLink(name: String, url: String)
    }
}

extension DependencyValues {
    var persistenceClient: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}

extension PersistenceClient: DependencyKey {
    static var liveValue: PersistenceClient = Self { item in
        let viewContext = PersistenceController.shared.container.viewContext
        switch item {
        case .favourite(let media):
            let favourite = CDFavourite(context: viewContext)
            favourite.mediaType = media.mediaType?.rawValue
            favourite.id = media.id?.int32 ?? 0
            favourite.title = media.displayName
            favourite.overview = media.overview
            favourite.posterPath = media.posterPath ?? media.profilePath
            favourite.backdropPath = media.backdropPath
            favourite.releaseDate = media.releaseDate ?? media.firstAirDate
            favourite.dateAdded = .init()
            try viewContext.save()
            return favourite
        case .watch(let media):
            let watch = CDWatch(context: viewContext)
            watch.mediaType = media.mediaType?.rawValue
            watch.id = media.id?.int32 ?? 0
            watch.title = media.displayName
            watch.overview = media.overview
            watch.posterPath = media.posterPath ?? media.profilePath
            watch.backdropPath = media.backdropPath
            watch.releaseDate = media.releaseDate ?? media.firstAirDate
            watch.dateAdded = .init()
            try viewContext.save()
            return watch
        case let .externalLink(name, url):
            let link = CDExternalLink(context: PersistenceController.shared.container.viewContext)
            link.url = url
            link.name = name
            try viewContext.save()
            return link
        }
    } deleteFromDatabase: {
        PersistenceController.shared.container.viewContext.delete($0)
        try PersistenceController.shared.container.viewContext.save()
        return nil
    } favouriteList: { mediaType, key, ascending in
        let request = NSFetchRequest<CDFavourite>(entityName: "Favourite")
        if mediaType != .all {
            request.predicate = .init(format: "mediaType == %@", mediaType.rawValue)
        }
        request.sortDescriptors = [ .init(key: key, ascending: ascending) ]
        return try PersistenceController.shared.container.viewContext.fetch(request)
    } favouriteItem: { id in
        guard let id else { return nil }
        let request = NSFetchRequest<CDFavourite>(entityName: "Favourite")
        request.fetchLimit = 1
        request.predicate = .init(format: "id == %i", id)
        return try PersistenceController.shared.container.viewContext.fetch(request).first
    } externalLinks: {
        let request = CDExternalLink.fetchRequest()
        return try PersistenceController.shared.container.viewContext.fetch(request)
    } watchlist: { mediaType, key, ascending in
        let request = NSFetchRequest<CDWatch>(entityName: "Watch")
        if mediaType != .all {
            request.predicate = .init(format: "mediaType == %@", mediaType.rawValue)
        }
        request.sortDescriptors = [ .init(key: key, ascending: ascending) ]
        return try PersistenceController.shared.container.viewContext.fetch(request)
    } watchItem: { id in
        guard let id else { return nil }
        let request = NSFetchRequest<CDWatch>(entityName: "Watch")
        request.fetchLimit = 1
        request.predicate = .init(format: "id == %i", id)
        return try PersistenceController.shared.container.viewContext.fetch(request).first
    }

    static var previewValue: PersistenceClient = Self { item  in
        switch item {
        case .favourite(let media):
            let favourite = CDFavourite(context: PersistenceController.preview.container.viewContext)
            favourite.id = 30
            favourite.mediaType = "movie"
            return favourite
        case .watch:
            return CDWatch(context: PersistenceController.preview.container.viewContext)
        case .externalLink:
            return CDExternalLink(context: PersistenceController.preview.container.viewContext)
        }
    } deleteFromDatabase: { _ in
        nil
    } favouriteList: { _, _, _ in
        mockMedias.map {
            let favourite = CDFavourite(context: PersistenceController.preview.container.viewContext)
            favourite.id = Int32($0.id ?? 0)
            favourite.mediaType = $0.mediaType?.rawValue
            favourite.title = $0.displayName
            favourite.posterPath = $0.posterPath ?? $0.profilePath
            return favourite
        }
    } favouriteItem: { _ in
        nil
    } externalLinks: {
        [("themoviedb", "https://www.themoviedb.org")]
            .map {
                let link = CDExternalLink(context: PersistenceController.preview.container.viewContext)
                link.name = $0.0
                link.url = $0.1
                return link
            }
    } watchlist: { _, _, _ in
        []
    } watchItem: { _ in
        nil
    }

    static var testValue: PersistenceClient = previewValue
}
