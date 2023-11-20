//
//  CreditReducer.swift
//  MovieDB
//
//  Created by allie on 20/11/2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CreditReducer {

    struct State: Equatable, Hashable {
        var credit: Media.Credits
        var combinedCredits: [Media.CombinedCredits]

        init(credit: Media.Credits) {
            self.credit = credit

            // MARK: - 演员列表
            combinedCredits = [
                .init(department: "Acting", credits: credit.cast?.map {
                    .init(
                        year: "",
                        title: $0.name ?? "",
                        character: $0.character ?? "",
                        posterPath: $0.profilePath,
                        id: $0.id
                    )
                } ?? []),
                .init(department: "Directing", credits: []),
                .init(department: "Writing", credits: [])
            ]

            // MARK: - 工作人员列表
            credit.crew?.forEach { crew in
                let item = Media.CombinedCredits.Credit(
                    year: "",
                    title: crew.name ?? "",
                    character: crew.job?.localized ?? "",
                    id: crew.id
                )
                if let index = combinedCredits.firstIndex(where: { $0.department == crew.department }) {
                    if !combinedCredits[index].credits.contains(where: { $0.id == crew.id }) {
                        combinedCredits[index].credits.append(item)
                    }
                } else {
                    combinedCredits.append(
                        .init(department: crew.department ?? "", credits: [ item ])
                    )
                }
            }

            combinedCredits.removeAll(where: { $0.credits.isEmpty })
        }
    }

    enum Action: Equatable {

    }

    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
