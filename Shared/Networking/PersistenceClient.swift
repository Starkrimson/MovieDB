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
    var favouriteList: @Sendable (_ filterBy: MediaType, _ sortBy: SortByKeyPath<Favourite>) throws -> [Favourite]
    var favouriteItem: @Sendable (Int?) throws -> Favourite?

    var externalLinks: @Sendable () throws -> [ExternalLink]
    var addExternalLink: @Sendable (_ name: String, _ url: String) throws -> ExternalLink
    var deleteExternalLink: @Sendable (ExternalLink) throws -> Bool
}

extension PersistenceClient {
    enum MarkAsFavourite {
        case remove(Favourite)
        case favourite(Media)
    }

    typealias SortByKeyPath<Root> = (keyPath: PartialKeyPath<Root>, ascending: Bool)
}

extension PartialKeyPath where Root == Favourite {
    var label: (key: String, localized: String) {
        switch self {
        case \Favourite.dateAdded:
            return ("dateAdded", "DATE ADDED".localized)
        case \Favourite.title:
            return ("title", "NAME".localized)
        case \Favourite.releaseDate:
            return ("releaseDate", "RELEASE DATE".localized)
        default:
            assertionFailure("Unexpected key path")
            return ("Unexpected", "Unexpected")
        }
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
            favourite.dateAdded = .init()
            try viewContext.save()
            return favourite
        case .remove(let favourite):
            viewContext.delete(favourite)
            try viewContext.save()
            return nil
        }
    } favouriteList: { mediaType, sort in
        let request = Favourite.fetchRequest()
        if mediaType != .all {
            request.predicate = .init(format: "mediaType == %@", mediaType.rawValue)
        }
        request.sortDescriptors = [ .init(key: sort.keyPath.label.key, ascending: sort.ascending) ]
        return try PersistenceController.shared.container.viewContext.fetch(request)
    } favouriteItem: { id in
        guard let id else { return nil }
        let request = Favourite.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id == %i", id)
        return try PersistenceController.shared.container.viewContext.fetch(request).first
    } externalLinks: {
        let request = ExternalLink.fetchRequest()
        return try PersistenceController.shared.container.viewContext.fetch(request)
    } addExternalLink: { name, url in
        let link = ExternalLink(context: PersistenceController.shared.container.viewContext)
        link.url = url
        link.name = name
        try PersistenceController.shared.container.viewContext.save()
        return link
    } deleteExternalLink: { link in
        PersistenceController.shared.container.viewContext.delete(link)
        try PersistenceController.shared.container.viewContext.save()
        return true
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
    } favouriteList: { _, _ in
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
    } externalLinks: {
        [("openai", "https://chat.openai.com"), ("sms-activate", "https://sms-activate.org")]
            .map {
                let link = ExternalLink(context: PersistenceController.preview.container.viewContext)
                link.name = $0.0
                link.url = $0.1
                return link
            }
    } addExternalLink: { _, _ in
        ExternalLink(context: PersistenceController.preview.container.viewContext)
    } deleteExternalLink: { _ in
        return false
    }

    static var testValue: PersistenceClient = previewValue
}
