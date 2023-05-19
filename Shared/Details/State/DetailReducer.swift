//
//  DetailReducer.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation
import ComposableArchitecture
import MovieDependencies

struct MovieState: Equatable, Hashable {
    var movie: Movie

    var directors: [Media.Crew]
    var writers: [Media.Crew]

    init(_ movie: Movie) {
        self.movie = movie
        directors = movie.credits?.crew?.filter { $0.department == "Directing" }.unique(\.id) ?? []
        writers = movie.credits?.crew?.filter { $0.department == "Writing" }.unique(\.id) ?? []
    }
}

struct TVState: Equatable, Hashable {
    var tvShow: TVShow

    var createdBy: [Media.Crew]

    init(_ tvShow: TVShow) {
        self.tvShow = tvShow

        createdBy = tvShow.createdBy?.unique(\.id) ?? []
    }
}

struct PersonState: Equatable, Hashable {
    var person: Person

    var knownFor: [Media.CombinedCredits.Credit]

    var combinedCredits: IdentifiedArrayOf<Media.CombinedCredits>

    var images: [Media.Image] {
        person.images?.profiles ?? []
    }

    init(_ person: Person) {
        self.person = person

        knownFor = {
            if person.knownForDepartment == "Acting" {
               return person.combinedCredits?.cast?
                    .unique(\.id)
                    .sorted(by: { $0.popularity ?? 0 > $1.popularity ?? 0})
                    .filter {
                        if $0.mediaType == .tvShow {
                            return $0.episodeCount ?? 0 >= 5
                        }
                        return true
                    }
                    .prefix(10)
                    .map(Media.CombinedCredits.Credit.from) ?? []
            } else {
                return person.combinedCredits?.crew?
                    .unique(\.id)
                    .sorted(by: { $0.popularity ?? 0 > $1.popularity ?? 0})
                    .prefix(10)
                    .map(Media.CombinedCredits.Credit.from) ?? []
            }
        }()

        let actingCredits: [Media.CombinedCredits.Credit] = person.combinedCredits?.cast?
            .sorted(by: >)
            .map(Media.CombinedCredits.Credit.from)
            .unique(\.id) ?? []

        combinedCredits = [
            .init(
                department: "Acting",
                credits: actingCredits
            )
        ]

        person.combinedCredits?.crew?.sorted(by: >)
            .forEach { crew in
                let department = crew.department ?? ""
                let credit = Media.CombinedCredits.Credit.from(crew)
                if combinedCredits.ids.contains(department) {
                    combinedCredits[id: department]?.credits.append(credit)
                } else {
                    combinedCredits.append(
                        .init(department: department, credits: [credit])
                    )
                }
            }
    }
}

struct DetailReducer: ReducerProtocol {

    struct State: Equatable, Identifiable, Hashable {
        var id: Media.ID? { media.id }

        let media: Media

        var detail: DetailState?

        var status: ViewStatus = .loading

        var favourite: CDFavourite?

        var isFavourite: Bool { favourite != nil }
    }

    enum DetailState: Equatable, Hashable {
        case movie(MovieState)
        case tvShow(TVState)
        case person(PersonState)
    }

    enum Action: Equatable {
        case fetchDetails
        case fetchDetailsResponse(TaskResult<DetailModel>)

        case markAsFavourite
        case favouriteResult(TaskResult<CDFavourite?>)
    }

    @Dependency(\.dbClient) var dbClient
    @Dependency(\.persistenceClient) var persistenceClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            enum DetailID { }

            switch action {
            case .fetchDetails:
                state.status = .loading
                return .merge(
                    .task { [media = state.media] in
                        await .fetchDetailsResponse(TaskResult<DetailModel> {
                            try await dbClient.details(media.mediaType ?? .movie, media.id ?? 0)
                        })
                    }
                    .animation()
                    .cancellable(id: DetailID.self),
                    .task { [id = state.media.id] in
                        await .favouriteResult(TaskResult<CDFavourite?> {
                            try persistenceClient.favouriteItem(id)
                        })
                    }
                )

            case .fetchDetailsResponse(.success(let detail)):
                state.status = .normal
                switch detail {
                case .movie(let movie):
                    state.detail = .movie(.init(movie))
                case .tvShow(let tvShow):
                    state.detail = .tvShow(.init(tvShow))
                case .person(let person):
                    state.detail = .person(.init(person))
                }
                return .none

            case .fetchDetailsResponse(.failure(let error)):
                state.status = .error(error.localizedDescription)
                customDump(error)
                return .none

            case.markAsFavourite:
                return .task { [media = state.media, favourite = state.favourite] in
                    await .favouriteResult(TaskResult<CDFavourite?> {
                        if let favourite {
                            return try persistenceClient.deleteFromDatabase(favourite) as? CDFavourite
                        }
                        return try persistenceClient.addItemToDatabase(.favourite(media)) as? CDFavourite
                    })
                }

            case .favouriteResult(.success(let favourite)):
                state.favourite = favourite
                return .none

            case .favouriteResult(.failure(let error)):
                customDump(error)
                return .none
            }
        }
    }
}
