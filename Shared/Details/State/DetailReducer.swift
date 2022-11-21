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
    var tv: TVShow
    
    var createdBy: [Media.Crew]
        
    init(_ tv: TVShow) {
        self.tv = tv
        
        createdBy = tv.createdBy?.unique(\.id) ?? []
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
                        if $0.mediaType == .tv {
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
            .map { cast -> Media.CombinedCredits.Credit in
                    .init(
                        year: String((cast.releaseDate ?? cast.firstAirDate ?? "").prefix(4)),
                        title: cast.title ?? cast.name ?? "",
                        character: cast.character.map({ "\("AS".localized) \($0)" }) ?? "",
                        mediaType: cast.mediaType,
                        posterPath: cast.posterPath,
                        backdropPath: cast.backdropPath,
                        id: cast.id
                    )
            }
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
                let credit = Media.CombinedCredits.Credit(
                    year: String((crew.releaseDate ?? crew.firstAirDate ?? "").prefix(4)),
                    title: crew.title ?? crew.name ?? "",
                    character: crew.job?.localized ?? "",
                    mediaType: crew.mediaType,
                    posterPath: crew.posterPath,
                    backdropPath: crew.backdropPath,
                    id: crew.id
                )
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
    }
    
    enum DetailState: Equatable, Hashable {
        case movie(MovieState)
        case tv(TVState)
        case person(PersonState)
    }
    
    enum Action: Equatable {
        case fetchDetails
        case fetchDetailsResponse(TaskResult<DetailModel>)
    }
    
    @Dependency(\.dbClient) var dbClient
        
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            enum DetailID { }
            
            switch action {
            case .fetchDetails:
                state.status = .loading
                return .task { [media = state.media] in
                    await .fetchDetailsResponse(TaskResult<DetailModel> {
                        try await dbClient.details(media.mediaType ?? .movie, media.id ?? 0)
                    })
                }
                .animation()
                .cancellable(id: DetailID.self)
                
            case .fetchDetailsResponse(.success(let detail)):
                state.status = .normal
                switch detail {
                case .movie(let movie):
                    state.detail = .movie(.init(movie))
                case .tv(let tv):
                    state.detail = .tv(.init(tv))
                case .person(let person):
                    state.detail = .person(.init(person))
                }
                return .none
                
            case .fetchDetailsResponse(.failure(let error)):
                state.status = .error(error.localizedDescription)
                customDump(error)
                return .none
            }
        }
    }
}
