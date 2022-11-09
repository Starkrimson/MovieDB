//
//  DetailReducer.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation
import ComposableArchitecture

struct MovieState: Equatable, Hashable {
    var movie: Movie
    
    var directors: [Media.Crew]
    var writers: [Media.Crew]
        
    init(_ movie: Movie) {
        self.movie = movie
        directors = movie.credits?.crew?.filter { $0.department == "Directing" } ?? []
        writers = movie.credits?.crew?.filter { $0.department == "Writing" } ?? []
    }
}

struct TVState: Equatable, Hashable {
    var tv: TVShow
    
    var createdBy: [Media.Crew]
        
    init(_ tv: TVShow) {
        self.tv = tv
        
        createdBy = tv.createdBy ?? []
    }
}

struct PersonState: Equatable, Hashable {
    var person: Person
    
    var knownFor: [Media.Cast]
    
    var combinedCredits: IdentifiedArrayOf<Media.CombinedCredits>

    var images: [Media.Image] {
        person.images?.profiles ?? []
    }
        
    init(_ person: Person) {
        self.person = person
        
        knownFor = Array(person.combinedCredits?.cast?
            .sorted(by: { $0.popularity ?? 0 > $1.popularity ?? 0})
            .prefix(10) ?? [])
        
        let actingCredits: [Media.CombinedCredits.Credit] = person.combinedCredits?.cast?
            .sorted(by: >)
            .map { cast -> Media.CombinedCredits.Credit in
                    .init(
                        year: String((cast.releaseDate ?? cast.firstAirDate ?? "").prefix(4)),
                        title: cast.title ?? cast.name ?? "",
                        character: cast.character.map({ "饰演 \($0)" }) ?? "",
                        mediaType: cast.mediaType,
                        posterPath: cast.posterPath,
                        backdropPath: cast.backdropPath,
                        id: cast.id
                    )
            } ?? []
        
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
                    character: crew.job ?? "",
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
        let mediaType: MediaType
        
        var detail: DetailState?
                    
        var status: ViewStatus = .loading
    }
    
    enum DetailState: Equatable, Hashable {
        case movie(MovieState)
        case tv(TVState)
        case person(PersonState)
    }
    
    enum Action: Equatable {
        case fetchDetails(mediaType: MediaType)
        case fetchDetailsResponse(TaskResult<DetailModel>)
    }
    
    @Dependency(\.dbClient) var dbClient
        
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            enum DetailID { }
            
            switch action {
            case .fetchDetails(mediaType: let mediaType):
                state.status = .loading
                return .task { [id = state.media.id] in
                    await .fetchDetailsResponse(TaskResult<DetailModel> {
                        try await dbClient.details(mediaType, id ?? 0)
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
